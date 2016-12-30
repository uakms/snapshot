// Author: nakinor
// Created: 2016-12-30
// Revised: 2016-12-30

import Foundation

var innerDict:[[String]] = []

func createDict(dictfile:String) {
    // 環境変数を得る(引数をパスの形にしてもらうことにしたのでコメントアウト)
    //let mtodir = ProcessInfo.processInfo.environment["MTODIC"]! + "/"
    //let dictfile = mtodir + dictfile

    // ちなみに `var tmpdict = [[]]` のようにすると、先頭に空の `[]` が入ってしまうよ
    // 外に出してグローバル化した
    //var tmpdict:[[String]] = []

    do {
        // 辞書ファイルのコメント行を削除するための正規表現
        let regexp1 = try NSRegularExpression(pattern: "^;.*|^$",
                                              options: [])

        // 辞書ファイルのコメント部分を削除するための正規表現
        let regexp2 = try NSRegularExpression(pattern: "\\s+;.*",
                                              options: [])

        // ファイルを開く
        let data = try String(contentsOfFile: dictfile,
                              encoding: String.Encoding.utf8)
        // 一行ずつ処理する
        data.enumerateLines(invoking: {
            line, stop in
            // コメント行を探す
            let match = regexp1.matches(in: line,
                                 options: [],
                                   range: NSMakeRange(0, (line as NSString).length))

            // コメント行ではなかったものについて処理
            if (match.count != 0) {
                // コメント行は無視
            } else {
                // 備考部分を削除
                let result =
                    regexp2.stringByReplacingMatches(in: line,
                                                options: [],
                                                  range: NSMakeRange(0, (line as NSString).length),
                                           withTemplate: "")
                // 二次元配列に代入
                innerDict.append(result.components(separatedBy: " /"))
            }
        })
    } catch let error as NSError {
        print(error)
    }
}

func replaceStringCar(infile:String) {
    let inputfile = infile
    do {
        let data = try String(contentsOfFile: inputfile,
                              encoding: String.Encoding.utf8)

        // 一行ずつ変換して出力する方法(遅い)
        /*
         data.enumerateLines(invoking: {
         line, stop in
         // immutable なのでコピーして mutable な文字列へ
         var str = line
         for cons in innerDict {
         str = str.replacingOccurrences(of: cons[0], with: cons[1])
         }
         print(str)
         })
         */
        // ファイルを一括で読み込んで変換し出力する方法(メモリをたくさんつかう)
        var str = data
        for cons in innerDict {
            str = str.replacingOccurrences(of: cons[0], with: cons[1])
        }
        print(str, terminator: "")
    } catch let error as NSError {
        print(error)
    }
}

func replaceStringCdr(infile:String) {
    let inputfile = infile
    do {
        let data = try String(contentsOfFile: inputfile,
                              encoding: String.Encoding.utf8)

        // 一行ずつ変換して出力する方法(遅い)
        /*
         data.enumerateLines(invoking: {
         line, stop in
         // immutable なのでコピーして mutable な文字列へ
         var str = line
         for cons in innerDict {
         str = str.replacingOccurrences(of: cons[0], with: cons[1])
         }
         print(str)
         })
         */
        // ファイルを一括で読み込んで変換し出力する方法(メモリをたくさんつかう)
        var str = data
        for cons in innerDict {
            str = str.replacingOccurrences(of: cons[1], with: cons[0])
        }
        print(str, terminator: "")
    } catch let error as NSError {
        print(error)
    }
}

func printUsage() {
    print("Usage: mto-swift options filename");
    print("options:");
    print("  tradkana        歴史的仮名使いに変換します");
    print("  modernkana      現代仮名使いに変換します");
    print("  oldkanji        旧字体に変換します");
    print("  newkanji        新字体に変換します");
    print("  checkdictkana   かな辞書の要素数を表示します");
    print("  checkdictkanji  漢字辞書の要素数を表示します");
}

func main() {
    // 環境変数が設定されているかどうかチェック
    let mtodir = ProcessInfo.processInfo.environment["MTODIC"]

    if mtodir == nil {
        print("環境変数 MTODIC を設定してください。")
        exit (1)
    }

    // 引数処理 (argc にあたるものは無いみたい)
    let args = ProcessInfo.processInfo.arguments
    let argc = args.count

    if (argc == 1 || argc >= 4) {
        printUsage()
        exit (1)
    } else {
        if argc == 2 {
            if args[1] == "checkdictkana" {
                let dictfilepath = mtodir! + "/kana-jisyo"
                // 引数を渡す時にラベルをつけないといけない
                // dictfile という仮引数に dictfilepath の内容を渡すよって感じかな
                createDict(dictfile:dictfilepath)
                print("かな辞書の語彙は現在 \(innerDict.count) です。")
                //print("checkdictkanaやな。")
            } else if args[1] == "checkdictkanji" {
                let dictfilepath = mtodir! + "/kanji-jisyo"
                createDict(dictfile:dictfilepath)
                print("漢字辞書の語彙は現在 \(innerDict.count) です。")
                //print("checkdictkanjiやな。")
            } else {
                print("Option ちゃうやん")
                printUsage()
            }
        } else if argc == 3 {
            if args[1] == "tradkana" {
                let dictfilepath = mtodir! + "/kana-jisyo"
                createDict(dictfile:dictfilepath)
                replaceStringCar(infile:args[2])
                //print("tradkanaやな。")
            } else if args[1] == "modernkana" {
                let dictfilepath = mtodir! + "/kana-jisyo"
                createDict(dictfile:dictfilepath)
                replaceStringCdr(infile:args[2])
                //print("modernkanaやな。")
            } else if args[1] == "oldkanji" {
                let dictfilepath = mtodir! + "/kanji-jisyo"
                createDict(dictfile:dictfilepath)
                replaceStringCar(infile:args[2])
                //print("oldkanjiやな。")
            } else if args[1] == "newkanji" {
                let dictfilepath = mtodir! + "/kanji-jisyo"
                createDict(dictfile:dictfilepath)
                replaceStringCdr(infile:args[2])
                //print("newkanjiやな。")
            } else {
                print("Option ちゃうやん")
                printUsage()
            }
        }
    }
}

main()
