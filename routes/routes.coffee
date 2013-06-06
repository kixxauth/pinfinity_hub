exports.routes = (route) ->

  route 'galleryIndex', 'GET,HEAD', '/hub/gallery', 'gallery index'
  route 'galleryWidgetPost', 'POST', '/hub/gallery', 'gallery widgetPost'
  route 'galleryWidgetFrame', 'GET,HEAD', '/hub/gallery/:widget/preview', 'gallery widgetFrame'
  route 'galleryWidgetFiles', 'GET,HEAD', '/hub/gallery/:widget/files/*', 'gallery widgetFiles'

  # TODO: The downloads endpoint should probably have its own controller.
  route 'galleryDownloads', 'GET,HEAD', '/hub/downloads/:id/*', 'gallery download'
