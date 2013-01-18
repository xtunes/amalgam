#= require jquery
#= require amalgam/mercury
#= require bootstrap-dropdown
#= require jquery.remotipart
#= require_self

$ = window.jQuery

findOrCreate = (selector,content)->
  if (el=$(selector)).length
    el
  else
    $(content).prependTo($('body')).hide()

Msg =
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

$ = jQuery
attachments_count = 0
$ ->
  @nav = $('.nav')
  topMargin = @nav.height()
  @editor = new Mercury.PageEditor mercury_prefix()+"/admin/editor",
                                    saveStyle:  "form"
                                    saveMethod: "PUT"
                                    visible:    false
  @editor.iframe.one 'load', ->
    if window.location.hash=='#edit'
      $(".nav .edit").trigger('click')

  sanitize_url = (url)->
    url = url.replace(Mercury.config.editorUrlRegEx,  "$1/$2")
    url = url.replace(/[\?|\&]mercury_frame=true/gi, '')
    url.replace(/\&_=i\d+/gi, '')

  $('.new_attachment').live 'click', (event) ->
    event.preventDefault
    target = $(event.target)
    type = target.data().type
    $('.attachment_list_' + target.attr('name')).append("<label for='page_描述'>描述</label><div><input id='"+type+"_attachment.description' name='[content]["+type+"s/" + target.data().modelId + ".attachments_attributes][value][" + attachments_count + "][description]' size='30' type='text'><br>
<input id='"+type+"_attachment.file' name='[content]["+type+"s/" + target.data().modelId + ".attachments_attributes][value][" + attachments_count + "][file]' type='file'>
<input id='"+type+"_attachment.name' name='[content]["+type+"s/"+ target.data().modelId + ".attachments_attributes][value][" + attachments_count + "][name]' type='hidden' value='" + $(event.target).attr('name') + "'></div>")
    attachments_count++
    return false

  $(".nav .edit").click (e) ->
    e.preventDefault()
    if window.Mercury
      Mercury.trigger("toggle:interface")

      buttons = $('#mercury_iframe').contents().find("button.properties")
      if $('.mercury-toolbar-container:hidden').length
        buttons.hide()
      else
        buttons.show()

  @editor.toolbar.show = ->
    @visible = true
    @element.css(top: topMargin, display: 'block')

  Mercury.on "saved", =>
    window.location.hash = ''
    window.location.href = "#{sanitize_url(window.location.href)}#edit"
    location.reload()
    # => TODO 只使iframe内部刷新
    # Msg.success('保存成功!')
    # @editor.loadIframeSrc(null)

  Mercury.on "resize", =>
    if typeof(@editor.toolbar.height()) == "number"
      toolbar_height = @editor.toolbar.height()
    else
      toolbar_height = @editor.toolbar.element.height()
    @editor.iframe.css
      top: toolbar_height + topMargin
      height: @editor.statusbar.top() - toolbar_height - topMargin

  Mercury.on 'ready', =>
    $($(".mercury-panel .mercury-panel-pane")[0]).css("visibility","visible")
    $('.mercury-panel-close').css("opacity", '1')
    @editor.iframe.contents().find("button.properties").click () ->
      getform($(this).data().url)
    # TODO 使加载的页面
    # $(@editor.iframe.get(0).contentWindow.document).on 'click','a', (e)->
    #   $target = $(e.target)
    #   if($target.attr('target') == '_parent' || $target.attr('target') == '_top')
    #     href = sanitize_url($target.attr('href'))
    #     if href != ''
    #       e.preventDefault()
    #       window.mercuryInstance.loadIframeSrc(href)
    #       if (Modernizr.history)
    #         history.pushState(null,null,href);

  $('.mercury-editproperties-button').click (event,state) ->
    if state != "button"
      if $('.mercury-editproperties-button.pressed').length
        $(".mercury-panel .mercury-panel-pane .content").html($('#mercury_iframe').contents().find('script#property-form').html())

  $(".mercury-preview-button").click (event,state) ->
    buttons = $('#mercury_iframe').contents().find("button.properties")
    if $('.mercury-preview-button.pressed').length
      buttons.hide()
    else
      buttons.show()

  getform = (src) ->
    $.ajax({
      url: src,
      type: "get",
      dataType: "html",
      success: (data) ->
        reg = /<script id=\"property-form\" type=\"text\/html\">([\s\S]*?)<\/script>/i
        result = reg.exec(data)
        if result != null && result.length > 1
          loadform(result[1])
      })

  loadform = (content=null) ->
    if $('.mercury-editproperties-button.pressed').length == 0
      $('.mercury-editproperties-button').trigger('click',['button'])

    $(".mercury-panel .mercury-panel-pane .content").find('form').remove()
    if content == null
      $(".mercury-panel .mercury-panel-pane .content").append($('#properties_frame').contents().find('script.properties').html())
    else
      $(".mercury-panel .mercury-panel-pane .content").append(content)


  fixHelper = (e, ui) ->
    ui.children().each () ->
      $(this).width($(this).width())
    ui

  # addsortable = () ->
  #   $('.attachmentlist tbody').sortable({
  #     helper: fixHelper,
  #     update: (event, ui) ->
  #       id = ui.item.attr("id")
  #       data = {}
  #       data['prev'] = ui.item.prev().attr("id") if ui.item.prev('tr').length
  #       data['next'] = ui.item.next().attr("id") if ui.item.next('tr').length

  #       $.ajax {
  #         url: "/admin/attachments/" + id + "/move",
  #         type: "POST",
  #         data: data,
  #         dataType: "html"
  #       }
  #     }).disableSelection()