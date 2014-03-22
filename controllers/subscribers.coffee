REQ = require 'request'

urlEncodedParser = require 'connect/lib/middleware/urlencoded'

STATIC_DOMAIN = process.env['STATIC_DOMAIN'] || 'www.pinfinity.co'

exports.controllers = (use, handler) ->
  formParser = urlEncodedParser()

  # The extendContext middleware is used for all requests.
  use extendContext

  handler 'post', formParser, post


post = (req, res, next) ->
  res.render (format, context) ->
      return @html(201, '/subscribers/show.html', context)

  opts =
    method: 'POST'
    uri: 'https://docs.google.com/a/pinfinity.co/forms/d/1KR1wOAU4YEkpnLZze8rGhuyK5WjHap4JNmUE89s9g9I/formResponse'
    form:
      'draftResponse': '[]'
      'entry.1188423636': req.body.list
      'entry.368323113': req.body.source
      'entry.1644706403': req.body.name
      'entry.1661031855': req.body.email
      'pageHistory': 0
    followRedirect: no
    jar: no
    encoding: 'utf8'

  console.log('Posting subscription request to Google Forms.')
  req = REQ.post opts, (err, res, body) ->
    if err
      console.error('Google Forms POST error:')
      console.error(err)
    else
      console.log('Google Forms POST response:', res.statusCode)
    return

  req.on 'error', (err) ->
    console.error('Google Forms Request error:')
    console.error(err)
    return


  res.finish()
  return

#
# Utilities
#

extendContext = (req, res, next) ->
    ext =
        static_domain: "http://#{STATIC_DOMAIN}"

    res.updateContext(ext)
    return next()
