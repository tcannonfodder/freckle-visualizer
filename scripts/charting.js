var Person = Class.create({
  initialize: function(name) {
    this.name = name;
  },
  say: function(message) {
    return this.name + ': ' + message;
  }
});

var Charting = Class.create({
  initialize: function(options) {
    this.options = Object.extend({
    	avgPerDay : $("avg_per_day"),
    	avgPerMonth : $("avg_per_month"),
    	loggedPerMonthOverTime : $("logged_per_month_over_time"),
    	loggedPerTagCombo : $("logged_per_tag_combo"),
    	typeTimeLogged : $("type_time_logged"),
    },options || {});
  },
  renderDailyChart: function(data) {

    this.avgPerDayChart = new Highcharts.Chart({
	  chart: {
		 renderTo: this.options.avgPerDay,
		 type: 'spline'
		},
		title: {
			text: 'Average Per Day'
		},
		tooltip: {
			pointFormat: '{series.name}: <b>{point.y}</b>'
		},
		xAxis: {
			categories: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
		},
		yAxis: {
			title: {
				text: 'Hours Logged'
			},
			min: 0 
		},
		series: data
	})
  }
});