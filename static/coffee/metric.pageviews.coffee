"use strict"

class MetricPageviews extends Backbone.View

  initialize: ()->
    @listenTo @model, "change:pageviews", @update

    return this

  template: """
  <h2>Pageviews</h2>

  <div class="info">from <span class="from"></span> to <span class="to"></span></div>

  <div class="row">
    <div class="col-md-2">
      <div class="action">
        <a class="json btn btn-default" role="button">json</a>
      </div>
    </div>

    <div class="col-md-10">
      <div class='preview'/>
    </div>
  """

  render: ()->
    @$el.empty()
    @$el.append @template

    console.log  @model.get("url:#{@attributes['metric']}")

    @$(".json").attr("href", @model.get("url:#{@attributes['metric']}"))

    return this

  update: ()->

    $el = @$el.find ".preview"

    h = 300
    # w = 900

    month_width = 15

    svg = d3.select "#metric-pageviews .preview"
      .append "svg"
      .style "width", "100%"
      .attr "height", h

    months = @model.get "pageviews"

    f = d3.time.format("%Y-%m-%d")

    days = {}

    for month in months
      _(month).each (value, day)->
        days[day] = value

    @$(".info .from").html _(days).keys()[0]
    @$(".info .to").html _(days).keys()[ _(days).size()-1 ]

    weeks = _(days).groupBy (v, k)-> d3.time.format("%Y-%U")(f.parse(k))

    console.log weeks

    start = 0
    end = 0

    max_month = d3.max _(months).map (month)-> d3.sum _(month).values()
    month_scale = d3.scale.linear().domain([0, max_month]).range([0, h])

      # for d in _(w).keys()
      #   console.log "day:", f.parse(d)

    month = svg.append "g"
      .selectAll ".month"
      .data months
      .enter()
        .append "g"
        .attr "class", "month"
        .attr "transform", (d,i)-> "translate(#{i*(month_width+1)},0)"

    month.append "rect"
      .attr "y", (d)-> h - month_scale d3.sum _(d).values()
      .attr "height", (d)-> month_scale d3.sum _(d).values()
      .attr "width", month_width
      .style "fill", "black"

    day = svg.append "g"
      .selectAll ".day"
      .data days
      .enter()
        .append "g"
        .attr "class", "day"
