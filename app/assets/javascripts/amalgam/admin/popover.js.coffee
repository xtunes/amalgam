# = require ./app

$ = window.jQuery

class App.Popover
	@template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div>'
	constructor: (@bind,@options={})->
		@options = $.extend({
			content: @bind.data('content')
			title: @bind.attr('title')
		},options)
		@el = $(@constructor.template).appendTo($('body')).hide()
	render: ->
		@el.find('.popover-title').html(@options.title)
		@el.find('.popover-content').html(@options.content)
		@position()

	position: ->
		visible = @el.is(':visible')
		@el.show()
		w = @el.width()
		h = @el.innerHeight()
		pos = $.extend {} , @bind.offset() ,{
			width: @bind[0].offsetWidth
			height: @bind[0].offsetHeight
		}
		padding = parseInt(@el.css('padding-left'))
		margin = 5
		$window = $(window)
		$arrow = @el.find('.arrow')
		view =
			top: $window.scrollTop()
			left: $window.scrollLeft()
			width: $window.width()
			height: $window.height()
		@el.css({ top: 0, left: 0, display: 'block' })
		@el.removeClass('top')
		@el.removeClass('bottom')
		tp = {}
		if (pos.left + w ) <= view.left + view.width
			tp.left = pos.left - padding
			$arrow.css('left', pos.width/2 + padding)
		else
			tp.left = pos.left + pos.width  - w - margin
			$arrow.css('left', w - pos.width/2 - padding)
		if (pos.top + pos.height + h) <= view.top + view.height
			#bottom
			cssClass = 'bottom'
			tp.top = pos.top + pos.height - margin
		else
			cssClass = 'top'
			tp.top = pos.top - h + margin
		@el.css(tp)
		@el.addClass(cssClass)
		@el.hide() if !visible
		@el

	toggle: ->
		if @el.is(':visible')
			@el.fadeOut('fast')
		else
			@render()
			@el.fadeIn('fast')
	content: (content) ->
		return options.content if !content
		@options.content = content
		@render()
	title: (title) ->
		return options.title if !title
		@options.title = title
		@render()

$.fn.popo = (options={})->
	$el = $(@)
	data = $el.data('app.popover')
	return data if data
	popover = new App.Popover($el,options)
	$el.data('app.popover',popover)
	return popover