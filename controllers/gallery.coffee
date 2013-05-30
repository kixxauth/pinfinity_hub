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


# Handler: Main gallery listing.
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


# Handler: Zip file uploads of HTML widgets.
widgetPost = (req, res, next) ->
    zip = req.files.gallery_file

    # Handle edge cases
    # 1) When there is no upload.
    if not zip
        err = "No file was chosen. Give it another try."

    # 2) When the mimetype is incorrect.
    else if zip.type isnt 'application/zip'
        err = "The uploaded file must be a zip file. Try renaming your file "
        err += "with a .zip extension and try again."

    # 3) When there are invalid characters in the name.
    if /[^\w\-\.]/.test(zip.name)
        err = "Sorry, a zip file name may contain only letters, dashes, "
        err += "underscores, and numbers. Try renaming it and uploading again."

    if err
        res.updateContext({error: err})
    else
        print res.body
        # saveWidget(zip.path, GALLERY)

    # Proceed to the index handler.
    return next()


# Handler: Render the HTML widget preview frame.
widgetFrame = (req, res, next) ->
    widgetId = req.params['widget']
    res.updateContext({item: widgetId})

    res.render (format, context) ->
        return @html(200, '/gallery/preview.html', context)

    res.finish()
    return


# Handler: Serve widget files from the widget package.
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
    static_domain = process.env['STATIC_DOMAIN'] || 'www.pinfinity.co'
    ext =
        static_domain: "http://#{static_domain}"
    res.updateContext(ext)
    return next()

# Extract a widget zip archive and write it to disk.
saveWidget = (sourcePath, targetRoot) ->
    zip = new ZIP(sourcePath)

    # Using a timestamp as UID should be good enough for now.
    id = new Date().getTime().toString()

    entries = zip.getEntries().forEach (entry) ->
        if not entry.isDirectory
            filepath = entry.entryName.split('/').slice(1).join('/')
            path = "#{targetRoot}/#{id}/#{filepath}"
            zip.extractEntryTo(entry.entryName, path)
        return

    return id
