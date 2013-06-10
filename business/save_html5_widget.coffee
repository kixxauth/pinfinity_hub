FS    = require 'fs'
NPATH = require 'path'
ZIP   = require 'adm-zip'
PLIST = require 'plist'

# FIXME: These configs should be environment specific settings.
exports.GALLERY  = '/var/pinfinity_hub/gallery'
exports.DATA     = '/var/pinfinity_hub/data'
exports.DWNLOADS = '/var/pinfinity_hub/downloads'
exports.TEMP     = '/tmp/pinfinity_hub'


exports.parseWidget = (opts) ->
    opts or= {}
    {widgetName, emailAddress, sourcePath, zipName, tempDirectory} = opts
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
