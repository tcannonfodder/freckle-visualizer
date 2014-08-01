require 'uri'
require 'net/http'
require 'json'

class APIClient
  attr_reader :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  def get_entries(parameters={})
    entries = []

    # make our initial request to the API
    response = request(base_uri(parameters))

    # add the entries in this first response to the entries array
    entries += JSON.parse(response.body)

    pagination_links = parse_pagination_header(response)
    while pagination_links[:last]
      response = request(pagination_links[:next])
      entries << JSON.parse(response.body)
    end

    entries
  end

  def parse_pagination_header(response)
    links = {}
    return links if response["Link"].nil?
    response["Link"].scan(/(<([^>]*)>; rel="(\w+)")+/).map{|match|
      links[match[2].to_sym] = match[1]
    }

    links
  end

  def base_uri(parameters)
    # Setup the base URL and query parameters for our API call
    base_url = "https://api.letsfreckle.com/v2/entries"
    query_parameters = parameters.merge(:per_page => 1000)

    URI.parse("#{base_url}?#{URI.encode_www_form(query_parameters)}")
  end

  def request(uri)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    # Create a new request and set the correct headers
    request = Net::HTTP::Get.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request["X-FreckleToken"] = api_key

    # Send request
    response = https.request(request)

    case response.code
      when "200"
        return response
      when "401"
        exception_class = Unauthorized
      when "403"
        exception_class = Forbidden
      when "400"
        exception_class = BadRequest
      when "503"
        exception_class = ServiceUnavailable
      else
        exception_class = UnknownError
    end

    error = JSON.parse(response.body)

    raise exception_class.new(error["message"], error["errors"])
  end

  class RequestError < StandardError
    attr_accessor :errors

    def initialize(message = nil, errors = nil)
      super(message)
      self.errors ||= errors
    end
  end

  Unauthorized       = Class.new(RequestError)
  Forbidden          = Class.new(RequestError)
  BadRequest         = Class.new(RequestError)
  ServiceUnavailable = Class.new(RequestError)
  UnknownError       = Class.new(RequestError)
end