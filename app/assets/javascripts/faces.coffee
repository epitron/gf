# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  decorate = (e)->
    e.draggable().resizable(handles: "se").tooltip()
    e.find(".delete-button").on 'click', ->
      $(this).parent(".region").remove()

  prototype_region = $("#prototype .region")

  decorate($(".photo-container .region"))

  $(".add-region").on 'click', ->
    new_region = prototype_region.clone()
    decorate(new_region)
    $('.photo-container').append(new_region)

  # $('.drag').click(->
  #   $(this).toggleClass 'selected'
  #   return
  # ).drag('init', ->
  #   if $(this).is('.selected')
  #     return $('.selected')
  #   return
  # ).drag('start', (ev, dd) ->
  #   dd.attr = $(ev.target).prop('className')
  #   dd.width = $(this).width()
  #   dd.height = $(this).height()
  #   return
  # ).drag (ev, dd) ->
  #   props = {}
  #   if dd.attr.indexOf('E') > -1
  #     props.width = Math.max(32, dd.width + dd.deltaX)
  #   if dd.attr.indexOf('S') > -1
  #     props.height = Math.max(32, dd.height + dd.deltaY)
  #   if dd.attr.indexOf('W') > -1
  #     props.width = Math.max(32, dd.width - dd.deltaX)
  #     props.left = dd.originalX + dd.width - props.width
  #   if dd.attr.indexOf('N') > -1
  #     props.height = Math.max(32, dd.height - dd.deltaY)
  #     props.top = dd.originalY + dd.height - props.height
  #   if dd.attr.indexOf('drag') > -1
  #     props.top = dd.offsetY
  #     props.left = dd.offsetX
  #   $(this).css props
