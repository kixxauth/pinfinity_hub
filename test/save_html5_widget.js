require('../node_modules/enginemill/enginemill');

describe("save_html5_widget", function () {
    var save_html5_widget = require("../business/save_html5_widget")

    describe("parseWidget()", function () {

        it("should return a data struct", function () {
            var struct = save_html5_widget.parseWidget();

            struct.id.should.be.a('string');
            struct.name.should.be.a('string');
            struct.owner.should.be.a('string');
            struct.filename.should.be.a('string');
            struct.height.should.be.a('number');
            struct.width.should.be.a('number');
            struct.mainHTML.should.be.a('string');

            struct.zip.extractAllTo.should.be.a('function');
            struct.zip.getEntries.should.be.a('function');
            struct.zip.getEntries().should.be.an.instanceOf(Array);
            return;
        });

        return; // parseWidget()
    });

    return; // save_html5_widget
});
