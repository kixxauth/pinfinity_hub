exports.controllers = (use, handler) ->

    handler 'index', index
    handler 'widgetPost', widgetPost
    handler 'widgetFrame', widgetFrame
    handler 'widgetFiles', widgetFiles

    return


index = (req, res, next) ->
    res.render (format, context) ->
        context = extendContext(context)
        return @html(200, '/gallery/index.html', context)
    res.finish()
    return

widgetPost = (req, res, next) ->
    console.log('POSTED')
    return next()

widgetFrame = (req, res, next) ->
    return next()

widgetFiles = (req, res, next) ->
    return next()

extendContext = (context) ->
    static_domain = process.env['STATIC_DOMAIN'] || 'www.pinfinity.co'
    ext =
        static_domain: "http://#{static_domain}"
    return extend(context, ext)
