var path = require('path');
var childProcess = require('child_process');
var phantomjs = require('phantomjs');
var binPath = phantomjs.path;

module.exports = function (grunt) {
    grunt.registerMultiTask('roll', 'Rolls a .js file', function () {
        var done = this.async();
        grunt.log.writeln('Rolling ' + this.data.src + ' -> ' + this.data.dest);

        var childArgs = [
            path.join(__dirname, '../phantomjs-script.js')
        ];

        childProcess.execFile(binPath, childArgs, function (err, stdout, stderr) {
            if (err) { console.log(err); }
            if (stdout) { console.log('stdout', stdout); }
            if (stderr) { console.log('stderr', stderr); }
            done();
        });
    });
};