require('../node_modules/enginemill/enginemill');

describe("save_html5_widget", function () {
    var save_html5_widget = require("../business/save_html5_widget")

    describe("parseWidget()", function () {

        it("should return a data struct", function () {
            var zipFixture = __dirname +'/fixtures/widgets/google-maps.wdgt.zip';

            var struct = save_html5_widget.parseWidget({
              widgetName: 'Boston Map Widget'
            , emailAddress: 'wdgt@example.com'
            , sourcePath: zipFixture
            , zipName: 'google-maps.wdgt.zip'
            , tempDirectory: '/tmp'
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
            struct.height.should.be.a('number');
            // The width from Info.plist.
            struct.width.should.be.a('number');
            // The declared mainHTML from Info.plist.
            struct.mainHTML.should.be.a('string');

            return;
        });

        return; // parseWidget()
    });

    return; // save_html5_widget
});
