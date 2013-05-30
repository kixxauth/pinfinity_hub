FS = require 'fs'
NPATH = require 'path'
ZIP = require 'adm-zip'

multipartParser = require 'connect/lib/middleware/multipart'
staticServer = require 'connect/lib/middleware/static'

GALLERY = '/var/pinfinity_hub/gallery'
DATA = '/var/pinfinity_hub/data'
TEMP = '/tmp/pinfinity_hub'


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
    entries = PATH.newPath(DATA).list().map (path) ->
        json = FS.readFileSync(path.toString(), 'utf8')
        return JSON.parse(json)

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
            saveWidget({
                widgetName: widgetName
                emailAddress: emailAddress
                sourcePath: zip.path
                targetRoot: GALLERY
            })
        catch err
            msg = "There was an unexpected error while processing your widget: "
            msg += (err.message or err.toString())
            res.updateContext({error: msg})

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
saveWidget = (opts) ->
    {widgetName, emailAddress, sourcePath, targetRoot} = opts
    zip = new ZIP(sourcePath)

    # Using a timestamp as UID should be good enough for now.
    id = new Date().getTime().toString()

    # Extract to a temporary location
    temp = "#{TEMP}/#{id}"
    zip.extractAllTo(temp, true)

    entries = zip.getEntries().forEach (entry) ->
        if not entry.isDirectory

            # Split off the zip file directory name.
            entrypath = entry.entryName.split('/').slice(1).join('/')

            # Create the target directory path.
            targetpath = "#{targetRoot}/#{id}/#{entrypath}"

            # Create the new target directory
            PATH.newPath(NPATH.dirname(targetpath)).mkdir()

            # Copy the file to the target location
            data = FS.readFileSync("#{temp}/#{entry.entryName}")
            FS.writeFileSync(targetpath, data)
        return

    widget =
        id: id
        name: widgetName
        owner: emailAddress

    # Save the widget meta to disk.
    datafile = "#{DATA}/#{id}.json"
    FS.writeFileSync(datafile, JSON.stringify(widget), 'utf8')
    return widget
