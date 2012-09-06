$ = window.jQuery
$win = $(window)

findOrCreate = (selector,content)->
  if (el=$(selector)).length
    el
  else
    $(content).prependTo($('body')).hide()

App =
  warnning: (msg)->
    @_msg("<span class=\"label label-warning\">#{msg}</span>")
  success: (msg)->
    @_msg("<span class=\"label label-success\">#{msg}</span>").delay(500).fadeOut ->
      $(@).remove()
  error: (msg)->
    @_msg("<span class=\"label label-important\">#{msg}</span>").click ->
      $(@).fadeOut ->
        $(@).remove()
  _msg: (content)->
    $loader = findOrCreate('#ajax-loader','<div id="ajax-loader"></div>')
    $loader.html(content);
    $loader.fadeIn();
  init: ->
    App.rebind()
    processScroll()
    $win.on('scroll',processScroll)

  rebind: ->
    $('[rel*=tooltip]').tooltip()

$(App.init)

$(document).on 'ajax:beforeSend' , '[data-remote]' , (e,xhr)->
  $el = $(e.target)
  msgLoading = $el.data('loading') || 'Loading...'
  msgDone = $el.data('done') || 'Done!'
  msgError = $el.data('error') || 'Error!'
  App.warnning(msgLoading)
  xhr.done ->
    App.success(msgDone)
    App.rebind()
  .fail ->
    App.error(msgError)

#fix scroll

processScroll = () ->
  scrollTop = $win.scrollTop()
  $('[data-scroll=fixed]').each ->
    el = $(@)
    navTop = el.data('app.navtop')
    if !navTop
      navTop = el.offset().top - 40
      el.data('app.navtop',navTop)
    substitute = el.next('.substitute')
    if !(substitute.length)
      substitute = $('<div class="substitute"/>').insertAfter(el)
      substitute.height(el.outerHeight()).hide()
    isFixed = el.is('.scroll_fixed')
    if scrollTop >= navTop && !isFixed
      el.addClass('scroll_fixed')
      substitute.show()
    else if (scrollTop <= navTop && isFixed)
      el.removeClass('scroll_fixed')
      substitute.hide()
    # console.log("#{scrollTop},#{navTop}")


window.App = App