get_url_params = ->
  v = {}
  params = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&')
  for param in params
     h = param.split("=")
     # 2つ目以降の=をなんとかする処理
     v[h.shift()] = h.join("=")
  return v

initialize = ->
  $.get(api_result, get_url_params(), (res) =>
    unless res["items"]
      return location.href = res["redirect_url"]

    last_score = 100000 # MATH.infinity
    rank = 0
    tie_count = 0

    # 新規追加メイン要素
    tr = document.createElement('tr')
    tr.setAttribute('style', 'border: 1px solid #000; border-collapse: collapse')
    # 新規追加右要素
    td_main = document.createElement('td')
    td_main.setAttribute('style', 'border: 1px solid #000; border-collapse: collapse')

    for item in res["items"]

      # スコアが異なる場合、全体への追加処理
      if last_score != item["score"]
        $('table#main_table').append(tr)

        rank += 1 + tie_count
        tie_count = 0

        # 要素のリセット
        tr = document.createElement('tr')
        tr.setAttribute('style', 'border: 1px solid #000; border-collapse: collapse')
        td_main = document.createElement('td')
        td_main.setAttribute('style', 'border: 1px solid #000; border-collapse: collapse')

        td_rank = document.createElement('td')
        td_rank.setAttribute('style', 'border: 1px solid #000; border-collapse: collapse')
        td_rank.setAttribute('text', rank)
        td_rank.appendChild(document.createTextNode(rank))
        tr.appendChild(td_rank)

        td_main = document.createElement('td')
      else
        tie_count++

      image_div = document.createElement('div')
      for image in item.images
        element = document.createElement('img')
        element.setAttribute('style', 'vertical-align: bottom')
        element.setAttribute('src', image)
        image_div.appendChild(element)

      td_main.appendChild(image_div)
      main_text = document.createTextNode(item.name)
      td_main.appendChild(main_text)
      tr.appendChild(td_main)

      last_score = item["score"]

    # 最後に余った追加要素を足す
    $('table#main_table').append(tr)

    # 短縮URLの表示
    $.get(api_shorten_url, { u: res["result_url"] }, (urls) =>
      $('div#shorten_url').append("<a href=" + urls["short_url"] + ">" + urls["short_url"] + "</a>")
    )
  )

window.onload = ->
  initialize()
