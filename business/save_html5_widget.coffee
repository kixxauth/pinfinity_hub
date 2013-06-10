FS    = require 'fs'
NPATH = require 'path'
ZIP   = require 'adm-zip'

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

    return rv

filterZipFiles = (entry) ->
    if entry.isDirectory then return false
    else return true
