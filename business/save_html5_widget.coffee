FS    = require 'fs'
NPATH = require 'path'
ZIP   = require 'adm-zip'
PLIST = require 'plist'

# FIXME: These configs should be environment specific settings.
exports.GALLERY  = '/var/pinfinity_hub/gallery'
exports.DATA     = '/var/pinfinity_hub/data'
exports.DWNLOADS = '/var/pinfinity_hub/downloads'
exports.TEMP     = '/tmp/pinfinity_hub'


# Public: Save an uploaded widget.
# 
# opts - An options Object hash.
#   .widgetName - The user given name of the widget.
#   .emailAddress - The user entered email address.
#   .sourcePath - The abspath where the file was temporarily persisted.
#   .zipName - The name of the uploaded zip file.
#
# Returns a widget meta Object hash.
exports.saveWidget = (opts, callback) ->
    widget = exports.parseWidget(opts)

    # Copy the individual zip file entries to the permanent location.
    widget.zipEntries.forEach (entry) ->

        # Split off the zip file directory name.
        entrypath = entry.split('/').slice(1).join('/')

        # Create the target directory path.
        targetpath = "#{exports.GALLERY}/#{widget.id}/#{entrypath}"

        # Create the new target directory
        PATH.newPath(NPATH.dirname(targetpath)).mkdir()

        # Copy the file to the target location
        src = "#{widget.tempExtractLocation}/#{entry}"
        FS.writeFileSync(targetpath, FS.readFileSync(src))
        return

    widget.location = PATH.newPath(exports.DWNLOADS, widget.id).mkdir()
    widget.location = widget.location.append(widget.zipname).toString()

    # Save the widget meta to disk.
    datafile = "#{exports.DATA}/#{widget.id}.json"
    FS.writeFileSync(datafile, JSON.stringify(widget), 'utf8')

    # Copy the zip file to a safe location for download.
    source = FS.createReadStream(widget.tempZipPath)
    sink = FS.createWriteStream(widget.location)
    # TODO: Add error handlers to source and sink.
    source.pipe(sink)

    if isFunction(callback) then sink.on('close', callback)
    return widget


exports.parseWidget = (opts) ->
    opts or= {}
    {widgetName, emailAddress, sourcePath, zipName} = opts
    rv = Object.create(null)
    rv.id = new Date().getTime().toString()
    rv.name = widgetName or 'unnamed'
    rv.owner = emailAddress or ''
    rv.zipname = zipName or "#{rv.id}.wdgt.zip"
    rv.tempZipPath = sourcePath

    # Extract the zip file.
    rv.tempExtractLocation = "#{exports.TEMP}/#{rv.id}"
    zip = new ZIP(sourcePath)
    zip.extractAllTo(rv.tempExtractLocation, yes)

    rv.zipEntries = zip.getEntries().filter(filterZipFiles).map (entry) ->
        return entry.entryName

    infoPlist = readInfoPlist(rv.tempExtractLocation, rv.zipEntries)
    if infoPlist then rv = defaults(rv, infoPlist)

    return rv


exports.getWidget = (id) ->
    path = PATH.newPath(exports.DATA).append(id + '.json').toString()
    json = FS.readFileSync(path, 'utf8')
    return JSON.parse(json)


exports.getAllWidgets = ->
    entries = PATH.newPath(exports.DATA).list().reverse().map (path) ->
        json = FS.readFileSync(path.toString(), 'utf8')
        return JSON.parse(json)
    return entries


filterZipFiles = (entry) ->
    if entry.isDirectory then return false
    else return true


readInfoPlist = (basePath, entries) ->
    for entry in entries

        # Make the comparison with only the basename (exclude the dirname), and
        # make it lowercase.
        if entry.split('/').pop().toLowerCase() is 'info.plist'
            path = PATH.newPath(basePath, entry).toString()
            return PLIST.parseFileSync(path)

    return null
