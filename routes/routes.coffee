exports.routes = (route) ->

  route 'ping', 'GET,HEAD', '/ping', 'ping get'
  route 'postSubscriber', 'POST', '/subscriptions', 'subscribers post'
