require('../node_modules/enginemill/enginemill');

describe("save_html5_widget", function () {
    var save_html5_widget = require("../business/save_html5_widget")

    describe("parseWidget()", function () {

      it("should extract zip and return a data struct", function () {
        var zipFixture = __dirname +'/fixtures/widgets/google-maps.wdgt.zip';

        var struct = save_html5_widget.parseWidget({
          widgetName: 'Boston Map Widget'
        , emailAddress: 'wdgt@example.com'
        , sourcePath: zipFixture
        , zipName: 'google-maps.wdgt.zip'
        });

        // The unique ID of the widget
        struct.id.should.be.a('string');

        // The human given name of the widget.
        struct.name.should.equal('Boston Map Widget');

        // The owner of the widget (email address).
        struct.owner.should.equal('wdgt@example.com');

        // The zip file name of the widget.
        struct.zipname.should.equal('google-maps.wdgt.zip');

        // The temporary path where the zip file was stored after upload.
        struct.tempZipPath.should.equal(zipFixture);

        // The directory where the zip file is extracted.
        struct.tempExtractLocation.should.be.a('string');

        // A list of zip entry names.
        struct.zipEntries.should.be.an.instanceOf(Array);
        struct.zipEntries.length.should.equal(15);
        struct.zipEntries.forEach(function (entry) {
          entry.should.be.a('string');
        });

        // The height from Info.plist.
        struct.Height.should.equal(768);
        // The width from Info.plist.
        struct.Width.should.equal(1024);
        // The declared mainHTML from Info.plist.
        struct.MainHTML.should.equal('main.html');

        var sourceDir = PATH.newPath(struct.tempExtractLocation);
        struct.zipEntries.forEach(function (entry) {
          var path = sourceDir.append(entry);
          path.exists().should.be.true;
        });

        return;
      });

      return; // parseWidget()
    });

    describe("saveWidget()", function () {
      var mocks = extend(Object.create(null), save_html5_widget);

      before(function () {
        save_html5_widget.GALLERY = PATH.root()
          .append('tmp', save_html5_widget.GALLERY)
          .mkdir().toString();

        save_html5_widget.DATA = PATH.root()
          .append('tmp', save_html5_widget.DATA)
          .mkdir().toString();

        save_html5_widget.DWNLOADS = PATH.root()
          .append('tmp', save_html5_widget.DWNLOADS)
          .mkdir().toString();
      });

      after(function () {
        save_html5_widget.GALLERY = mocks.GALLERY;
        save_html5_widget.DATA = mocks.DATA;
        save_html5_widget.DWNLOADS = mocks.DWNLOADS;
      });

      it('saves a widget to disk', function (done) {
        var zipFixture = __dirname +'/fixtures/widgets/google-maps.wdgt.zip'
          , struct

        function callback() {
          var widget
            , location = PATH.newPath(save_html5_widget.DWNLOADS)
                           .append(struct.id)

            , jsonPath = PATH.newPath(save_html5_widget.DATA)
                           .append(struct.id +'.json')

          // All the zip entries should be in a new basepath.
          struct.zipEntries.forEach(function (entry) {
            entry = entry.split('/').slice(1).join('/')

            var path = PATH.newPath(save_html5_widget.GALLERY)
              .append(struct.id, entry)

            path.exists().should.be.true;
          });

          widget = require(jsonPath.toString());

          // The height from Info.plist.
          widget.Height.should.equal(768);
          // The width from Info.plist.
          widget.Width.should.equal(1024);
          // The declared mainHTML from Info.plist.
          widget.MainHTML.should.equal('main.html');

          // The unique ID of the widget
          widget.id.should.be.a('string');

          // The human given name of the widget.
          widget.name.should.equal('Boston Map Widget');

          // The owner of the widget (email address).
          widget.owner.should.equal('wdgt@example.com');

          // The zip file name of the widget.
          widget.zipname.should.equal('google-maps.wdgt.zip');

          // The dowload source location.
          widget.location.should.equal(
            location.append(widget.zipname).toString());

          return done();
        }

        struct = save_html5_widget.saveWidget({
          widgetName: 'Boston Map Widget'
        , emailAddress: 'wdgt@example.com'
        , sourcePath: zipFixture
        , zipName: 'google-maps.wdgt.zip'
        }, callback);
      });

      return; // saveWidget()
    });

    return; // save_html5_widget
});
