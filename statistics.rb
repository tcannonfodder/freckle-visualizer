require 'date'

class Statistics
  attr_reader :api_key
  attr_accessor :params

  def initialize(api_key, params = {})
    raise ArgumentError, "please provide an API key" if api_key.nil? or api_key.strip.empty?
    @api_key = api_key.strip
    @params = params
  end

  def per_day
    day_of_week_lambda = lambda{ |x|
      date = Date.strptime(x["date"], "%Y-%m-%d")
      return date.strftime("%A")
    }

    return basic_stats_per_category(Date::DAYNAMES, day_of_week_lambda)
  end

  def per_month
    day_of_week_lambda = lambda{ |x|
      date = Date.strptime(x["date"], "%Y-%m-%d")
      return date.strftime("%B")
    }

    return basic_stats_per_category(Date::MONTHNAMES.compact, day_of_week_lambda)
  end

  def per_month_in_time
    months_with_year = []
    earliest_entry = entries.last
    earliest_date = Date.strptime(earliest_entry["date"], "%Y-%m-%d")

    start_date = params[:from].nil? ? earliest_date : params[:from]
    end_date   = params[:to].nil? ? Date.today : params[:to]

    number_of_years = end_date.year - start_date.year
    number_of_years = 1 if number_of_years <= 0

    number_of_months = (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)

    number_of_months.times{ |x|
      months_with_year << (start_date >> x).strftime("%B - %Y")
    }

    month_with_year_lambda = lambda{ |x|
      date = Date.strptime(x["date"], "%Y-%m-%d")
      return date.strftime("%B - %Y")
    }

    return basic_stats_per_category(months_with_year, month_with_year_lambda)
  end

  def per_project
    projects_lambda = lambda{|x| x["project"].nil? ? nil : x["project"]["id"] }
    project_ids = projects_in_entries.map{|x| x.nil? ? nil : x["id"] }
    stats = basic_stats_per_category(project_ids, projects_lambda)
    results = stats.map{ |project_id, stat|
      stats_with_details = if project_id.nil?
        stat
      else
        projects_in_entries.find{|x| x && x["id"] == project_id}.merge(stat)
      end
      [project_id, stats_with_details]
    }.to_h
    return results
  end

  def per_tag
    tag_ids = tags_in_entries.map{|x| x["id"]}
    results = tag_ids.map{|x| [x, basic_stats_hash]}.to_h
    entries.each do |entry|
      entry["tags"].each do |tag|
        add_entry_to_stats_hash(results, tag["id"], entry)
      end
    end

    results = results.map{ |tag_id, stats|
      [tag_id, tags_in_entries.find{|x| x["id"] == tag_id}.merge(stats)]
    }.to_h

    average_stats_hash(results)
  end

  def per_tag_combination
    results = {}
    entries.each do |entry|
      tag_combo = entry["tags"].map{|x| "#{x["name"]}#{x["billable"] ? '' : '*'}"}.join(', ')
      add_entry_to_stats_hash(results, tag_combo, entry)
    end

    average_stats_hash(results)
  end

  def per_entry_type
    results = {
      :billable => {
        :count => 0,
        :total_minutes => 0
      },
      :unbillable => {
        :count => 0,
        :total_minutes => 0
      }
    }
    entries.each do |entry|
      status = entry["billable"] ? :billable : :unbillable
      results[status][:count] += 1
      results[status][:total_minutes] += entry["minutes"]
    end

    results = results.each{ |status, stats|
      stats[:average_minutes] = stats[:total_minutes].to_f/stats[:count] rescue 0
    }

    return results
  end

  def projects_in_entries
    entries.map{|x| x["project"]}.uniq
  end

  def tags_in_entries
    found_tags = []
    entries.map{|x| found_tags += x["tags"]}
    return found_tags.uniq
  end

  def entries
    @entries = APIClient.new(api_key).get_entries(params) if refresh_data?
    @entries
  end

  protected

  def basic_stats_hash
    {
      :total_count => 0,
      :total_minutes => 0,
      :billable_count => 0,
      :billable_minutes => 0,
      :unbillable_count => 0,
      :unbillable_minutes => 0
    }
  end

  def basic_stats_per_category(categories, category_name_lambda)
    results = {}
    categories.each{ |category| results[category] = basic_stats_hash.dup }

    entries.each do |entry|
      category_name = category_name_lambda.call(entry)
      add_entry_to_stats_hash(results, category_name, entry)
    end

    average_stats_hash(results)
    return results
  end

  def add_entry_to_stats_hash(results, category_name, entry)
    # if a new category was found, create a hash so that these stats are loaded
    results[category_name] = basic_stats_hash.dup if results[category_name].nil?

    results[category_name][:total_count] += 1
    results[category_name][:total_minutes] += entry["minutes"]

    if entry["billable"]
      results[category_name][:billable_count] += 1
      results[category_name][:billable_minutes] += entry["minutes"]
    else
      results[category_name][:unbillable_count] += 1
      results[category_name][:unbillable_minutes] += entry["minutes"]
    end
  end

  def average_stats_hash(results)
    results.each do |category_name,hash|
      next if hash[:total_count] == 0

      hash[:average_total_minutes] = hash[:total_minutes].to_f/hash[:total_count] rescue 0

      if hash[:billable_count] == 0
        hash[:average_billable_minutes] = 0
      else
        hash[:average_billable_minutes] = hash[:billable_minutes].to_f/hash[:billable_count] rescue 0
      end

      if hash[:unbillable_count] == 0
        hash[:average_unbillable_minutes] = 0
      else
        hash[:average_unbillable_minutes] = hash[:unbillable_minutes].to_f/hash[:unbillable_count] rescue 0
      end
    end

    return results
  end

  def refresh_data?
    if @cached_api_key != api_key || @cached_params != params
      @cached_api_key = api_key
      @cached_params = params
      return true
    end

    return false
  end
end