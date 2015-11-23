/*
 * Author: nakinor
 * Created: 2015-11-08
 * Revised: 2015-11-23
 */

var kanajisyo = process.env["MTODIR"] + '/dict/kana-jisyo';
var kanjijisyo = process.env["MTODIR"] + '/dict/kanji-jisyo';
var dicarr = [];
var fs = require('fs');

function dictCreator(jisyo) {
    var buf = fs.readFileSync(jisyo, 'utf8');
    var lines = buf.split('\n');
    for (var i = 0; i < lines.length; i++) {
        if (lines[i].match(/^;.*|^$/)) {
        } else {
            var str = gsub(lines[i], /\s+;.*/, "");
            var pairs = str.split(' /');
            dicarr.push(pairs);
        }
    }
}

function stringCarReplacer(ifile) {
    try {
        var buf = fs.readFileSync(ifile, 'utf8');
        for (var i = 0; i < dicarr.length; i++) {
            buf = gsub(buf, dicarr[i][0], dicarr[i][1]);
        }
        process.stdout.write(buf);
    }
    catch (err) {
        if (err['code'] == "ENOENT") {
            console.log("ファイルを開けませんでした");
        } else {
            console.log("しらんがな");
        }
    }
}

function stringCdrReplacer(ifile) {
    try {
        var buf = fs.readFileSync(ifile, 'utf8');
        for (var i = 0; i < dicarr.length; i++) {
            buf = gsub(buf, dicarr[i][1], dicarr[i][0]);
        }
        process.stdout.write(buf);
    }
    catch (err) {
        if (err['code'] == "ENOENT") {
            console.log("ファイルを開けませんでした");
        } else {
            console.log("しらんがな");
        }
    }
}

function gsub(str, key, val) {
    return str.split(key).join(val);
}

function usage() {
    console.log("Usage: node", process.argv[1], "options filename");
    console.log("options:");
    console.log("  tradkana      歴史的仮名使いに変換します");
    console.log("  modernkana    現代仮名使いに変換します");
    console.log("  oldkanji      旧字体に変換します");
    console.log("  newkanji      新字体に変換します");
}

function argParser() {
    if (process.argv.length < 3) {
        console.log("オプションを指定してください");
        usage();
    } else if (process.argv[2] == "tradkana") {
        dictCreator(kanajisyo);
        stringCarReplacer(process.argv[3]);
    } else if (process.argv[2] == "modernkana") {
        dictCreator(kanajisyo);
        stringCdrReplacer(process.argv[3]);
    } else if (process.argv[2] == "oldkanji") {
        dictCreator(kanjijisyo);
        stringCarReplacer(process.argv[3]);
    } else if (process.argv[2] == "newkanji") {
        dictCreator(kanjijisyo);
        stringCdrReplacer(process.argv[3]);
    } else {
        console.log("オプション間違ってない？");
        usage();
    }
}

function main() {
    if (process.env["MTODIR"] == undefined ) {
        console.log("環境変数 MTODIR を設定してください");
    } else {
        argParser();
    }
}

main()
