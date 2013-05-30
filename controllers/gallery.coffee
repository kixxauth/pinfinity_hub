FS = require 'fs'
NPATH = require 'path'
ZIP = require 'adm-zip'

multipartParser = require 'connect/lib/middleware/multipart'

GALLERY = '/var/pinfinity_hub/gallery'


exports.controllers = (use, handler) ->

    multipart = multipartParser()

    handler 'index', index
    handler 'widgetPost', multipart, widgetPost, index
    handler 'widgetFrame', widgetFrame
    handler 'widgetFiles', widgetFiles

    return


index = (req, res, next) ->

    # List all the gallery entries from the directory.
    entries = PATH.newPath(GALLERY).list().map (path) ->
        return NPATH.basename(path)

    # Filter out names that begin with an underscore. (namely __MACOSX)
    entries = entries.filter (name) ->
        return not /^_/.test(name)

    res.render (format, context) ->
        context.entries = entries
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
    if /[^\w\-\.]/.test(zip.name)
        msg = "Sorry, a zip file name may contain only letters, dashes, underscores, and numbers."
        msg += "Go back and try again."
        throw new Error(msg)

    archive = new ZIP(zip.path)
    archive.extractAllTo(GALLERY)
    return next()


widgetFrame = (req, res, next) ->
    return next()


widgetFiles = (req, res, next) ->
    return next()


#
# Utilities
#

extendContext = (context) ->
    static_domain = process.env['STATIC_DOMAIN'] || 'www.pinfinity.co'
    ext =
        static_domain: "http://#{static_domain}"
    return extend(context, ext)
