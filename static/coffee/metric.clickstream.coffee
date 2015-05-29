"use strict"

class MetricClickstream extends Backbone.View

  initialize: ()->
    @listenTo @model, "change:#{@attributes['metric']}", @update

    return this

  template: """
  <h2>Clickstream</h2>

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

    @$(".json").attr("href", @model.get("url:#{@attributes['metric']}"))
    @$(".preview").append('<div id="sankey" />')

    return this

  update: ()->
    data = @model.get @attributes['metric']

    center = @model.get "title"

    links_in = _.chain(data["in"])
      .pairs()
      .map (l)-> { source: "s:#{l[0]}", target: "o:#{center}", value: parseInt(l[1]) }
      .filter (l)-> l["source"].indexOf("other-") == -1
      .sortBy (l)-> -l["value"]
      .first(10)
      .value()

    links_out = _.chain(data["out"])
      .pairs()
      .map (l)-> { target: "t:#{l[0]}", source: "o:#{center}", value: parseInt(l[1]) }
      .filter (l)-> l["target"].indexOf("other-") == -1
      .sortBy (l)-> -l["value"]
      .first(10)
      .value()

    links = _.chain(links_in)
      .union(links_out)
      .value()

    console.log links

    nodes = _.chain(links)
      .map (l)-> [ l["target"], l["source"] ]
      .flatten()
      .uniq()
      .map (n)-> { name: n }
      .value()

    links = _(links).map (l)->
      link =
        source: _(nodes).findIndex (n)-> n["name"] == l["source"]
        target: _(nodes).findIndex (n)-> n["name"] == l["target"]
        value: l["value"]

    console.log nodes

    h = 300

    color = d3.scale.category20()

    d3.select("#sankey").selectAll("*").remove()

    svg = d3.select("#sankey")
      .append("svg")
      .style "width", "100%"
      .attr("height", h)

    w = svg.node().getBoundingClientRect().width

    sankey = d3.sankey()
      .nodeWidth(15)
      .nodePadding(10)
      .size([ w, h])

    path = sankey.link();

    sankey
      .nodes(nodes)
      .links(links)
      .layout(32)

    node = svg.append("g").selectAll(".node")
      .data(nodes)
      .enter().append("g")
      .attr("class", "node")
      .attr "transform", (d)-> "translate(" + d.x + "," + d.y + ")"
      .call(d3.behavior.drag()
        .origin (d)-> d
        .on "dragstart", ()-> this.parentNode.appendChild(this)
        .on("drag", dragmove))

    node.append("rect")
      .attr("height", (d)-> d.dy)
      .attr("width", sankey.nodeWidth())
      .style("fill", (d)-> d.color = color(d.name.split(":",2)[1]))
      .style("stroke", (d)-> d3.rgb(d.color).darker(2))
      .append("title")
      .text((d)-> d.name)

    node.append("text")
      .attr("x", -6)
      .attr("y", (d)-> d.dy/2)
      .attr("dy", ".35em")
      .attr("text-anchor", "end")
      .attr("transform", null)
      .text((d)-> d.name.split(":",2)[1])
      .filter((d)-> d.x < w / 2)
      .attr("x", 6 + sankey.nodeWidth())
      .attr("text-anchor", "start")

    link = svg.append("g").selectAll(".link")
      .data(links)
      .enter().append("path")
      .attr("class", "link")
      .attr("d", path)
      .style("stroke-width", (d)-> Math.max(1, d.dy))
      .sort((a, b)-> b.dy - a.dy)

    dragmove = (d)->
      d3.select(this).attr("transform", "translate(" + d.x + "," + (d.y = Math.max(0, Math.min(h - d.dy, d3.event.y))) + ")")
      sankey.relayout()
      link.attr("d", path)
