FS = require 'fs'
ZIP = require 'adm-zip'

multipartParser = require 'connect/lib/middleware/multipart'


exports.controllers = (use, handler) ->

    multipart = multipartParser()

    handler 'index', index
    handler 'widgetPost', multipart, widgetPost, index
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
    zip = req.files.gallery_file

    if not zip
        throw new Error("No file uploaded. Go back and try again.")
    if zip.type isnt 'application/zip'
        throw new Error("The uploaded file must be a zip file. Go back and try again.")

    archive = new ZIP(zip.path)
    archive.extractAllTo('/var/pinfinity_hub/gallery')
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
