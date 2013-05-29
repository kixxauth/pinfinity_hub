exports.controllers = (use, handler) ->

    handler 'index', index
    handler 'widgetPost', widgetPost
    handler 'widgetFrame', widgetFrame
    handler 'widgetFiles', widgetFiles

    return


index = (req, res, next) ->
    res.render (format, context) ->
        return @html(200, '/gallery/index.html', context)
    res.finish()
    return

widgetPost = (req, res, next) ->
    return next()

widgetFrame = (req, res, next) ->
    return next()

widgetFiles = (req, res, next) ->
    return next()
