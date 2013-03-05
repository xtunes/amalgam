# The image region is designed for a single, stand-along image and allows drag & drop uploading of a replacement right
# into the page, but provides no editing of other DOM attributes at this time.
class @Mercury.Regions.Image extends Mercury.Region
  @supported: document.getElementById
  @supportedText: "Chrome 10+, Firefox 4+, IE 7+, Safari 5+, Opera 8+"
  type = 'image'
  type: -> type

  constructor: (@element, @window, @options = {}) ->
    super


  bindEvents: ->
    Mercury.on 'mode', (event, options) => @togglePreview() if options.mode == 'preview'

    Mercury.on 'focus:frame', =>
      return if @previewing || Mercury.region != @
      @focus()

    Mercury.on 'action', (event, options) =>
      return if @previewing || Mercury.region != @
      @execCommand(options.action, options) if options.action

    @element.on 'dragenter', (event) =>
      return if @previewing
      event.preventDefault()
      event.originalEvent.dataTransfer.dropEffect = 'copy'

    @element.on 'dragover', (event) =>
      return if @previewing
      event.preventDefault()
      event.originalEvent.dataTransfer.dropEffect = 'copy'

    @element.on 'drop', (event) =>
      return if @previewing
      if event.originalEvent.dataTransfer.files.length
        event.preventDefault()
        @focus()
        options = {}
        if(@element.data().imageId)
          options.image_id = @element.data().imageId
        if(@element.data().thumb)
          options.thumb = @element.data().thumb
        Mercury.uploader(event.originalEvent.dataTransfer.files[0],options)

    @element.on 'focus', =>
      @focus()


  togglePreview: ->
    if @previewing
      @previewing = false
      @element.attr(Mercury.config.regions.attribute, type)
      @build()
    else
      @previewing = true
      @element.removeAttr(Mercury.config.regions.attribute)
      Mercury.trigger('region:blurred', {region: @})

  focus: ->
    return if @previewing
    Mercury.region = @
    Mercury.trigger('region:focused', {region: @})
    Mercury.trigger('region:update', {region: @})


  execCommand: (action, options = {}) ->
    super
    handler.call(@, options) if handler = Mercury.Regions.Image.actions[action]


  pushHistory: () ->
    @history.push(src: @element.attr('src'))
    @history.push(uid: @element.data().imageId)


  updateSrc: (src,id) ->
    @element.attr('src', src)
    if id
      @element.data().imageId = id


  serialize: ->
    return {
      type: type
      data: @dataAttributes()
      attributes:
        src: @element.attr('src')
        image_id: @element.data().imageId
    }


  @actions: {

    undo: -> if prev = @history.undo() then @updateSrc(prev.src,prev.uid)

    redo: -> if next = @history.redo() then @updateSrc(next.src,prev.uid)

    insertImage: (options) ->
      @updateSrc(options.value.src,options.value.uid)

  }
