exports.routes = (route) ->

  route 'galleryIndex', 'GET,HEAD', '/hub/gallery', 'gallery index'
  route 'galleryWidgetPost', 'POST', '/hub/gallery', 'gallery widgetPost'
  route 'galleryWidgetFrame', 'GET,HEAD', '/hub/gallery/:widget/frame', 'gallery widgetFrame'
  route 'galleryWidgetFiles', 'GET,HEAD', '/hub/gallery/:widget/files/*', 'gallery widgetFiles'
