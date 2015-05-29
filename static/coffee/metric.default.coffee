"use strict"

class MetricDefault extends Backbone.View

  initialize: ()->
    @listenTo @model, "change:#{@attributes['metric']}", @update

    return this

  template: """
  <h2></h2>

  <div class="row">
    <div class="col-md-2">
      <div class="action">
        <a class="json btn btn-default">json</a>
      </div>
    </div>

    <div class="col-md-10">
      <div class='preview'/>
    </div>

  </div>
  """

  render: ()->
    @$el.empty()
    @$el.append @template

    @$("h2").html @attributes["metric"]

    dataset_url = @model.get("url:#{@attributes['metric']}")

    @$(".json").attr("href", dataset_url)

    return this

  update: ()->
    dataset_url = @model.get("url:#{@attributes['metric']}")

    # $.get dataset_url, (data)=>
    #   @$(".preview").html data

    return this
