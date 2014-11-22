var fs = require('fs');

var page = require('webpage').create();

page.open('about:blank', function (status) {
    if (status !== 'success') { return; }

    [
        'lib/escodegen.browser.js',
        'lib/esprima.js',
        'lib/es6-collections.js',
        'build/jsroller.min.js'
    ].forEach(function (lib) { page.injectJs(lib); });

    try {
        var min = fs.read('build/jsroller.min.js');

        var rolled = page.evaluate(function (min) {
            return window.roller.obfuscate(min);
        }, min);

        fs.write('build/jsroller.roll.js', rolled, 'w');
    } catch (e) {
        console.log(e);
    }

    phantom.exit();
});