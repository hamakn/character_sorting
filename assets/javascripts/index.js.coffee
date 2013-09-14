match_lists = []
input_length = 0
enough_input = 100
seed = "undefined"
inputs = ""

$ ->
  $("div#image_left").click ->
    update_inputs(0)
    update_match()

  $("div#image_right").click ->
    update_inputs(1)
    update_match()

  $("td#draw").click ->
    update_inputs(2)
    update_match()

  $("td#no_interest").click ->
    update_inputs(3)
    update_match()

  $("div#image_left").css("cursor", "pointer")
  $("div#image_right").css("cursor", "pointer")
  $("td#draw").css("cursor", "pointer")
  $("td#no_interest").css("cursor", "pointer")

initialize = ->
  update_match()

update_inputs = (input) ->
  inputs += input.toString(10)
  input_length += 1

update_match_lists = ->
  params = {
    c: inputs,
    l: input_length,
    s: seed
  }
  $.get(api_lists, params, (res) =>
    # もし結果があれば、結果ページに遷移する
    if res["result_url"]
      location.href = res["result_url"]
    else
      match_lists = res["items"]
      seed = res["seed"]
      enough_input = res["count"]["enough"]
      update_match()
  )

update_match = ->
  if match_lists.length > 0
    match = match_lists.shift()
    left = match.shift()
    right = match.shift()

    $('div#image_left').empty()
    for image in left.images
      element = document.createElement('img')
      element.setAttribute("style", "vertical-align: bottom")
      element.setAttribute("src", image)
      $('div#image_left').append(element)

    $('div#image_right').empty()
    for image in right.images
      element = document.createElement('img')
      element.setAttribute("style", "vertical-align: bottom")
      element.setAttribute("src", image)
      $('div#image_right').append(element)

    $('div#label_left').text(left.name)
    $('div#label_right').text(right.name)

    $('div#match_no').text('Match No.' + (input_length + 1))
    $('div#progress').text(Math.floor(input_length * 10000 / enough_input) / 100 + '%')

  else
    update_match_lists()

window.onload = ->
  initialize()
