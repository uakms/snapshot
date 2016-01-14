# 微笑み方
こちらの[記事](http://sci.hateblo.jp/entry/Benchmarking2)の付録です。それぞれのスクリプトは短かいので、実際に動作をさせなくてもスクリプトを読んだだけで脳内実行・デバッグ・リファクタリング・クリティカルパスの発見ができてしまうのではありませんか？

## Emacs での利用
25.1.50 で動作を確認しています。ブラグイン形式の [emacs-mto](http://github.com/nakinor/emacs-mto) を使います。

## Vim での利用
7.4.1089 で動作を確認しています。ブラグイン形式の [vim-mto](http://github.com/nakinor/vim-mto) を使います。

## その他のスクリプトでの利用
カレントディレクトリが snapshot であるとします。

### CLISP
かつて 2.49 での動作を確認しましたが、現マシンでは clisp をビルドできないので確認していません。ライブラリの cl-ppcre-2.0.7 が必要です。

    clisp tool/mto-clisp.lisp tradkana README.md

### SBCL
1.3.1.222 で動作を確認しています。ライブラリの cl-ppcre-2.0.11 が必要です。

    sbcl --script tool/mto-sbcl.lisp tradkana README.md

### Lua
5.3.2 で動作を確認しています。

    lua tool/mto.lua tradkana README.md

### Perl5
5.18.2 で動作を確認しています。

    perl tool/mto.pl tradkana README.md

### Python3
3.5.1 で動作確を認しています。

    python3 tool/mto.py tradkana README.md

### Ruby
2.4.0dev で動作を確認しています。また、mruby でも動作しますが、`mruby-io` と、 `mruby-regexp-pcre` もしくは `mruby-onig-regexp` を組み込んでビルドしておいてください。

    ruby tool/mto.rb tradkana README.md
    mruby tool/mto.rb tradkana README.md

### Gauche
0.9.5_pre1 で動作を確認しています。

    gosh tool/mto.scm tradkana README.md

### Go
1.5.2 で動作を確認しています。辞書へのパスを環境変数から探すので、`export MTODIR="/Users/path/to/snapshot"` 等で `MTODIR` を設定しておいてください。

    go run tool/mto.go tradkana README.md

もしくは実行ファイルにして

    go build tool/mto.go
    ./mto tradkana README.md

### CSharp
momo 4.2.1 で動作を確認しています。辞書へのパスを環境変数から探すので、`export MTODIR="/Users/path/to/snapshot"` 等で `MTODIR` を設定しておいてください。

    mcs tool/mto-mono.cs
    mono mto-mono.exe tradkana README.md

### Objective-C
Xcode 7.2 で動作を確認しています。辞書へのパスを環境変数から探すので、`export MTODIR="/Users/path/to/snapshot"` 等で `MTODIR` を設定しておいてください。

    clang -framework Foundation tool/osx/main.m tool/osx/MTODict.m -o mto-objc
    ./mto-objc tradkana README.md

### C
Xcode 7.2 で動作を確認しています。辞書へのパスを環境変数から探すので、`export MTODIR="/Users/path/to/snapshot"` 等で `MTODIR` を設定しておいてください。

    cc mto.c -o mto
    ./mto tradkana README.md

### Node.js
4.2.4 で動作を確認しています。辞書へのパスを環境変数から探すので、`export MTODIR="/Users/path/to/snapshot"` 等で `MTODIR` を設定しておいてください。

    node tool/mto-node.js tradkana README.md

## その他のスクリプトについて
ユーティリティみたいなやつ。

### conv.go
辞書をチェックしたり数えたり JSON っぽく出力します。

    go run tool/conv.go -c dict/kana-jisyo

### jisyo-converter.rb
`conv.go` を作成する前に使っていたものです。カレントディレクトリにファイルが出力されます。

    ruby tool/jisyo-converter.rb

### word-count.sh
`conv.go` を作成する前に使っていたものです。辞書の要素数や簡易的なチェックをします。

    sh tool/word-count.sh

### mto.js
この[ページ](http://github.com/nakinor/mto)で利用している JavaScript です。実はこれが結構速かったりします。ブラウザのエンジンが優秀なのか、`split` and `join` が `replace` よりも速いからなのか。

ストップウォッチ利用なので、ちゃんと計測するには いっちぃにぃ さんの作成した [sjsp](https://github.com/itchyny/sjsp) プロファイラ等を利用するのがいいのかも。

### osx ディレクトリ
ごにょごにょ。IDE で作成したプロジェクトってどのファイルを公開していいのかわからないんだよね。プロファイルに本名とか書かれちゃってるし……

`MTOAppDelegate.h` と `MTOAppDelegate.m` と `MainMenu.xib` が Cocoa 用です。

### win ディレクトリ
ガサガサッ。IDE で作成したプロジェクトってどのファイルを公開していいのかわからないんだよね。プロファイルに本名とか書かれちゃってるし……

`MtoGW.exe.config` と `MtoGW_Form1.cs` と `MtoGW_Form2.cs` と `MtoGW_Program.cs` が Visual Studio 2008 Express で作成したものです。

# 変換サンプル文字列
「ゑ」になる代表を使った段落。

木を植えて石を据えれば庭となる。仕事をすれば飢えることなし。笑う門には福来たる。それご冗談でしょう？ご忠告ありがとうございます。

<blockquote>
このようにクオートされている部分を無視するオプションを付けてみた。実装できているのは Perl, Python, Ruby, Lua だけである。タグは同一行にあったりネストしていると期待通りの動作をしてくれない。
</blockquote>

いかにも旧字っぽくなりそうでならない「老い」などを使った段落。

その事について私がどうしようと私の勝手ですよね？たとえ老いた時に悔いる結果となったとしても、報いはその時に受けるでしょう。絶えず何かに怯えている心。甘えだとわかっているがゆえに吠えずにはいられない。煮え切らない自分の心の弱さに悶え苦しんで消え入りそうな日々。増えていくフィギュアと萌えるアニメで一時的に癒える表面的な心。すっかり冷えてしまった心を再び燃えあがらせて凍える夜を超えてゆけ。

単漢字タグ付けの変換確認をする部分。

Vim でこのファイルを開いているのであれば、`\p` とキーを押してみましょう。何か變化はありましたか？無ければ `~/.vimrc` にごにょごにょ書きましょう。`\p` の他にも `\h` と `\l` でも變化があります。変換の都度 `u` でアンドゥしてくださいね。

こういったデモンストレーション用のサンプルファイルは、大抵うまく變換できるように文章と辭書を調整しているもの。だからこいつで試しても無意味だっ！

風邪氣味なのでお醫者さんの處に行こうかと思っているのだけど、やっぱり怖いので鹽水でうがいをして遣り過すのであった。

今頃になって漢字のふりがなを付けるのではなく、舊字體を新字體にして添付してやる形にすれば良いと思った。この場合は nokaco の漢字辭書を流用できるもの。う〜、失敗。まぁ、それはいつかやればいいや。あと、色付けすると變換した場所がわかるけど目がチカチカして良くないのね。
