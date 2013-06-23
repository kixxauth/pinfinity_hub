FS    = require 'fs'
NPATH = require 'path'
ZIP   = require 'adm-zip'

multipartParser = require 'connect/lib/middleware/multipart'
staticServer    = require 'connect/lib/middleware/static'

saveHTML5Widget = require '../business/save_html5_widget'

GALLERY       = saveHTML5Widget.GALLERY
DWNLOADS      = saveHTML5Widget.DWNLOADS
STATIC_DOMAIN = process.env['STATIC_DOMAIN'] || 'www.pinfinity.co'


exports.controllers = (use, handler) ->

    multipart = multipartParser()
    widgetServer = staticServer(GALLERY)
    downloadServer = staticServer(DWNLOADS)

    # The extendContext middleware is used for all requests.
    use extendContext

    handler 'index', index
    handler 'widgetPost', multipart, widgetPost, index
    handler 'widgetFrame', widgetFrame
    handler 'widgetFiles', widgetFiles, widgetServer
    handler 'download', download, downloadServer

    return


# Handler: Main gallery listing.
index = (req, res, next) ->
    all = saveHTML5Widget.getAllWidgets()
    entries = all.reduce( (entries, item, i) ->
        col = i % 3
        entries[col].push(item)
        return entries
    , [[],[],[]])

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

    widgetName = req.body['widget_name'] or zip.name
    emailAddress = req.body['email_address'] or 'NA'

    if err
        res.updateContext({error: err})
    else
        try
            saveHTML5Widget.saveWidget({
                widgetName: widgetName
                zipName: zip.name
                emailAddress: emailAddress
                sourcePath: zip.path
            })
        catch err
            msg = "There was an unexpected error while processing your widget: "
            msg += (err.message or err.toString())
            console.error(msg)
            res.updateContext({error: msg})

    # Proceed to the index handler.
    return next()


# Handler: Render the HTML widget preview frame.
widgetFrame = (req, res, next) ->
    widgetId = req.params['widget']
    widget = saveHTML5Widget.getWidget(widgetId)
    res.updateContext({item: widget})

    res.render (format, context) ->
        return @html(200, '/gallery/preview.html', context)

    res.finish()
    return


# Handler: Serve widget files from the widget package.
widgetFiles = (req, res, next) ->
    widgetId = req.params['widget']

    # We have to rewrite the request path before the static handler gets it.
    parts = decodeURIComponent(req.path).split('/').slice(5)
    reqURL = "/#{widgetId}/#{parts.join('/')}"

    parts = GALLERY.split('/').concat(reqURL.split('/'))
    abspath = pathFromArray(parts)
    if not abspath.exists()
        reqURL = reqURL.toLowerCase()

    req.url = reqURL
    return next()


# Handler: Download a file from the downloads directory.
download = (req, res, next) ->
    id = req.params['id']

    # We have to rewrite the request path before the static handler gets it.
    req.url = "#{id}/#{name}"
    return next()


#
# Utilities
#

extendContext = (req, res, next) ->
    ext =
        static_domain: "http://#{STATIC_DOMAIN}"
    res.updateContext(ext)
    return next()


pathFromArray = (arr) ->
    path = PATH.newPath.apply(PATH, arr)
    if arr[0] is '' then path = PATH.newPath('/'+ path)
    return path
