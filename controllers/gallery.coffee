FS = require 'fs'
NPATH = require 'path'
ZIP = require 'adm-zip'

multipartParser = require 'connect/lib/middleware/multipart'
staticServer = require 'connect/lib/middleware/static'

GALLERY = '/var/pinfinity_hub/gallery'


exports.controllers = (use, handler) ->

    multipart = multipartParser()
    widgetServer = staticServer(GALLERY)

    # The extendContext middleware is used for all requests.
    use extendContext

    handler 'index', index
    handler 'widgetPost', multipart, widgetPost, index
    handler 'widgetFrame', widgetFrame
    handler 'widgetFiles', widgetFiles, widgetServer

    return


index = (req, res, next) ->

    # List all the gallery entries from the directory.
    entries = PATH.newPath(GALLERY).list().map (path) ->
        return NPATH.basename(path)

    # Filter out names that begin with an underscore. (namely __MACOSX)
    entries = entries.filter (name) ->
        return not /^_/.test(name)

    res.updateContext({entries: entries})

    res.render (format, context) ->
        return @html(200, '/gallery/index.html', context)

    res.finish()
    return


widgetPost = (req, res, next) ->
    zip = req.files.gallery_file

    if not zip
        throw new Error("No file uploaded. Go back and try again.")
    if zip.type isnt 'application/zip'
        throw new Error("The uploaded file must be a zip file. Go back and try again.")
    if /[^\w\-\.]/.test(zip.name)
        msg = "Sorry, a zip file name may contain only letters, dashes, underscores, and numbers."
        msg += "Go back and try again."
        throw new Error(msg)

    archive = new ZIP(zip.path)
    archive.extractAllTo(GALLERY)
    return next()


widgetFrame = (req, res, next) ->
    widgetId = req.params['widget']
    res.updateContext({item: widgetId})

    res.render (format, context) ->
        return @html(200, '/gallery/preview.html', context)

    res.finish()
    return


widgetFiles = (req, res, next) ->
    widgetId = req.params['widget']

    # We have to rewrite the request path before the static handler gets it.
    parts = req.path.split('/').slice(5)
    req.url = "#{widgetId}/#{parts.join('/')}"
    return next()


#
# Utilities
#

extendContext = (req, res, next) ->
    print !!req, !!res, !!next
    static_domain = process.env['STATIC_DOMAIN'] || 'www.pinfinity.co'
    ext =
        static_domain: "http://#{static_domain}"
    res.updateContext(ext)
    return next()
