module.exports = async function (context) {
    var cp = require('child_process');
    async function spawn(cmd, args) {
        return new Promise((resolve, reject) => {
            console.log("spawning " + cmd);
            var runner = cp.spawn(cmd, args, { encoding: 'utf-8' });
            runner.stdout.on('data', function (info) {
                process.stdout.write(info);
            });
            runner.stderr.on('data', (info) => {
                process.stdout.write(info);
            });
            runner.on('exit', (code) => {
                console.log(cmd + " exit code is " + code);
                if (code == 0) {
                    resolve()
                } else {
                    reject(cmd + " exit code is " + code)
                }
            });
            runner.on('error', (err) => {
                console.log(cmd + " error is ", err);
                reject(err)
            });
        })
    }
    console.log("running beforePluginInstall on ", process.cwd());
    if (process.platform == "win32") {
        await spawn("cmd", ["/c", "plugins\\cordova-plugin-tesseract\\scripts\\beforePluginInstall.bat"]);
    } else {
        await spawn("./plugins/cordova-plugin-tesseract/scripts/beforePluginInstall.sh");
    }
}