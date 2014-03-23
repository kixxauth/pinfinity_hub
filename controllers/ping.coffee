exports.controllers = (use, handler) ->
  handler 'get', return_pong
  return

return_pong = (req, res, next) ->
  res.render (format, context) ->
    response =
      statusCode: 200
      headers: {'Content-Type': 'text/plain'}
      body: 'pong\n'
    return response

  res.finish()
  return
