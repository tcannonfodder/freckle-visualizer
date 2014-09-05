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
    	billableType : $("billable_unbillable")
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
  },
 renderMonthlyChart: function(data) {

    this.avgPerMonthChart = new Highcharts.Chart({
	  chart: {
		 renderTo: this.options.avgPerMonth,
		 type: 'spline'
		},
		title: {
			text: 'Average Per Month'
		},
		tooltip: {
			pointFormat: '{series.name}: <b>{point.y}</b>'
		},
		xAxis: {
			categories: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
		},
		yAxis: {
			title: {
				text: 'Hours Logged'
			},
			min: 0 
		},
		series: data
	})
  },
 renderLoggedPerMonthChart: function(data) {

    this.loggedPerMonthOverTimeChart = new Highcharts.Chart({
	  chart: {
		 renderTo: this.options.loggedPerMonthOverTime,
		 type: 'spline'
		},
		title: {
			text: 'Logged Per Month Over Time'
		},
		tooltip: {
			pointFormat: '{series.name}: <b>{point.y}</b>'
		},
		xAxis: {
			categories: ['June 2014', 'July 2014', 'August 2014']
		},
		yAxis: {
			title: {
				text: 'Hours Logged'
			},
			min: 0 
		},
		series: data
	})
  },
 renderloggedPerTagCombo: function(data) {

    this.loggedPerTagComboChart = new Highcharts.Chart({
		chart: {
			renderTo: 'logged_per_tag_combo',
			backgroundColor: '#89B640',
			borderColor: '#339900',
			borderRadius: "10",
			borderWidth: '0',
			margin: [40],
			padding: [40],
			plotShadow: false
		},
		title: {
			text: 'Time Logged Per Tag Combo',  style: {color: "#ffffff"}
		},
		tooltip: {
			pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
		},
		plotOptions: {
			pie: {
				allowPointSelect: false,
				dataLabels: {
				color: '#ffffff'
				}
			}
		},
		series: data
	})
  },
 renderProjectChart: function(data) {

    this.projectSpreadChart = new Highcharts.Chart({
		chart: {
			renderTo: 'type_time_logged',
			backgroundColor: '#89B640',
			borderColor: '#339900',
			borderRadius: "10",
			borderWidth: '0',
			margin: [40],
			padding: [40],
			plotShadow: false
		},
		title: {
			text: 'Project Time Spread',  style: {color: "#ffffff"}
		},
		tooltip: {
			pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
		},
		plotOptions: {
			pie: {
				allowPointSelect: false,
				dataLabels: {
				color: '#ffffff'
				}
			}
		},
		series: data
	})
  },
 renderBillableChart: function(data) {

    this.billableSpreadChart = new Highcharts.Chart({
		chart: {
			renderTo: 'billable_unbillable',
			backgroundColor: '#89B640',
			borderColor: '#339900',
			borderRadius: "10",
			borderWidth: '0',
			margin: [40],
			padding: [40],
			plotShadow: false
		},
		title: {
			text: 'Billable/Unbillable Spread',  style: {color: "#ffffff"}
		},
		tooltip: {
			pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
		},
		plotOptions: {
			pie: {
				allowPointSelect: false,
				dataLabels: {
				color: '#ffffff'
				}
			}
		},
		series: data
	})
  },
});