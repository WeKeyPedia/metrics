"use strict"

class Page extends Backbone.Model

  initialize: ()->
    console.log "model:", this

    @available_views =
      pageviews: MetricPageviews
      clickstream: MetricClickstream

    @views =
      "summary": new PageViewSummary({ model: this, el: "#summary" }).render()
    #  "metric-pageviews": new MetricPageviews({ model: this, el: "#metric-pageviews" })

    @get_available_metrics()

    return this

  get_available_metrics: ()->

    $.get "/#{@get('title')}/in-#{@get('domain')}", (data)=>
      metrics = data["metrics"]

      $el = $("#visualizations")

      for metric in metrics
        @set "url:#{metric}", "/#{@get('title')}/in-#{@get('domain')}/#{metric}"

        div = $("<div/>")
          .attr("id", "metric-#{metric}")
          .addClass("metric")

        div.appendTo $("#visualizations")

        if metric not in _(@available_views).keys()
          v = MetricDefault
        else
          v = @available_views[metric]

        @views["metric-#{metric}"] = new v
          model: this
          el: "#metric-#{metric}"
          attributes:
            metric: metric

        @views["metric-#{metric}"].render()

        @fetch_metric(metric)

    return this

  fetch_metric: (metric)->

    $.get @get("url:#{metric}"), (res)=>
      @set metric, res["data"]

    return this

class PageViewSummary extends Backbone.View

  initialize: ()->
    console.log "view:", this
    @listenTo(@model, "change:info", @update)

    return this

  render: ()->
    @$el.empty()

    @$el.append "<h1>#{@model.get('title')}</h1>"

    @$el.append "<div id='info' />"
    @renderInfo()

    return this

  renderInfo: ()->
    info =
      revisions: 0
      editors: 0

    html = """
      <div>revisions: {{revisions}}</div>
      <div>editors: {{editors}}</div>
    """

    t = Handlebars.compile html
    @$el.find('#info').html t info

    return this
