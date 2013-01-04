$ = window.jQuery
$ ->
  return unless $('.tree').length
  $(document).on 'click','.tree .inner', (e)->
    return unless($(e.target).is('.inner, span:not(.badge)'))
    e.stopPropagation()
    $(@).siblings('form').slideToggle('fast')

  $tree = $('div > ol.tree')
  dataPath = $tree.data('path')
  msgDone = $tree.data('done')
  msgError = $tree.data('error')
  param = $tree.data('param')
  if($tree.data('path').indexOf('?') >= 0)
    dataPath = $tree.data('path').substring(0,$tree.data('path').indexOf('?'))

  $('div > ol.tree').nestedSortable
      helper: 'clone'
      items: 'li'
      opacity: .6
      forcePlaceholderSize: true
      placeholder: 'placeholder'
      tabSize: 60
      tolerance: 'pointer'
      handle: '.inner'
      toleranceElement: '> div'
      revert: 250
      update: (e,ui)->
        data = {}
        data["#{param}[parent_id]"] = ui.item.parents('[data-id]').data('id')
        data["#{param}[prev_id]"] = ui.item.prevAll('[data-id]').data('id')
        data["#{param}[next_id]"] = ui.item.nextAll('[data-id]').data('id')
        $.ajax
          type: 'PUT'
          url: "#{dataPath}/#{ui.item.data('id')}"
          data: data
          dataType: 'script'
          beforeSend: ->
            #
          success: ->
            App.rebind()
            App.success(msgDone || 'Updated!')
          error: ->
            App.error(msgError || 'Move Error!')

  $(document).on 'click', '.btn-add' , (e)->
    e.preventDefault()
    el = $(@)
    form = el.data('content')
    unless form
      $.ajax
        url: el.attr('href')
        dataType: 'html'
        beforeSend: (xhr)->
          xhr.setRequestHeader('Accept', 'text/javascript');
        success: (data)->
          el.data('content',data)
          el.popo().content(data)
      el.popo(content: 'Loading...')
      el.popo().el.on 'click', '.btn-cancel' , (e)->
        e.preventDefault()
        el.trigger('click') if el.popo().el.is(':visible')
      el.popo().el.on 'ajax:success','form' , ->
        el.trigger('click') if el.popo().el.is(':visible')

    $(@).popo().toggle()