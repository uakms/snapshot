//
//  MTOAppDelegate.m
//  CocoaMto
//
//  Created by nakinor on 2014/01/08.
//  Copyright (c) 2014-2017年 nakinor. All rights reserved.
//

#import "MTOAppDelegate.h"

@implementation MTOAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [_inputTextArea setFont:[NSFont fontWithName:@"Hiragino Maru Gothic ProN W4" size:14.0]];
    [_resultTextArea setFont:[NSFont fontWithName:@"Hiragino Maru Gothic ProN W4" size:14.0]];
}

// ウインドウを閉じたらアプリケーションを終了する
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

// 内部辞書を作成する
- (id)createDict:(NSString *)dictFile {
    NSString *pathToDictFile = dictFile;
    NSString *dictText = [NSString stringWithContentsOfFile:pathToDictFile
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    // 辞書ファイルのコメント行を削除するための正規表現
    NSString *commentLinePat = @"^;.*|^$";
    // 辞書ファイルのコメント部分を削除するための正規表現
    NSString *commentPartFromPat = @"\\s+;.*";
    // コメント部分を削除(空)にするためのもの
    NSString *commentPartToPat = @"";
    // 改行文字で区切って配列に格納する
    NSArray *dictLines = [dictText componentsSeparatedByString:@"\n"];
    // 作業用のテンポラリ配列
    NSMutableArray *tmpInnerDict = [NSMutableArray array];

    // コメント行を削除するための正規表現オブジェクト
    NSRegularExpression *regexpDeleteCommentLine =
    [NSRegularExpression regularExpressionWithPattern:commentLinePat
                                              options:0
                                                error:nil];

    // 改行文字で区切って配列に収納した辞書を 1 行(要素)ずつ処理していく
    for (NSString *line in dictLines) {
        NSTextCheckingResult *matchShouldDeleteLine =
        [regexpDeleteCommentLine firstMatchInString:line
                                            options:0
                                              range:NSMakeRange(0, line.length)];

        if (matchShouldDeleteLine.numberOfRanges) {
            // コメント行であれば何もしない
            // 続く処理でテンポラリ配列に追加されないので、つまり削除されることになる
        } else {
            // 辞書の要素となるべき語彙に付加した備考コメントを削除するための
            // 正規表現オブジェクト
            // 例えば「笑う /笑ふ ;ハ行四段」という要素であった時に、
            // commentPartFromPat で " ;ハ行四段" を見つけて commentPartToPat で置き換える
            // この結果「笑う /笑ふ」の部分だけを得られる
            NSRegularExpression *regexpDeleteCommentPart =
            [NSRegularExpression regularExpressionWithPattern:commentPartFromPat
                                                      options:0
                                                        error:nil];
            NSString *result =
            [regexpDeleteCommentPart stringByReplacingMatchesInString:line
                                                              options:0
                                                                range:NSMakeRange(0,line.length)
                                                         withTemplate:commentPartToPat];
            // 「笑う /笑ふ」を " /" で split して、テンポラリ配列に追加していく
            [tmpInnerDict addObject:[result componentsSeparatedByString:@" /"]];
        }
    }
    _innerDict = tmpInnerDict;
    return self;
}

// アラートダイアログで辞書の要素数を表示する
- (IBAction)showDictInfo:(id)sender {
    NSString *dictInfo = [[MTOAppDelegate alloc] calcDictElems];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"変換辞書の要素数について..."];
    [alert setInformativeText:dictInfo];
    [alert runModal];
}

- (NSString *)calcDictElems {
    NSString *kanadict = [[NSBundle mainBundle] pathForResource:@"kana-jisyo" ofType:nil];
    NSString *kanjidict = [[NSBundle mainBundle] pathForResource:@"kanji-jisyo" ofType:nil];
    NSInteger kana = [[[MTOAppDelegate alloc] createDict:kanadict] countOfInnerDict];
    NSInteger kanji = [[[MTOAppDelegate alloc] createDict:kanjidict] countOfInnerDict];
    NSString *infoString =
    [NSString stringWithFormat:@"辞書の語彙は %lu です\n\n　仮名変換用：%lu\n　漢字変換用：%lu",
     kana + kanji, kana, kanji];
    return infoString;
}

- (NSInteger)countOfInnerDict {
    return [_innerDict count];
}

//　内部辞書を初期化する(しなくても期待通りに動いているのだが...)
- (void)clearDict {
    [_innerDict removeAllObjects];
}

// 異体字(IVS)を削除する
- (NSString *)deleteIVS:(NSString *)text {
    // パーセントエスケープ
    NSString *escapedText = (NSString *)CFBridgingRelease
    (CFURLCreateStringByAddingPercentEscapes(NULL,
                                             (CFStringRef)text,
                                             NULL,
                                             CFSTR("!*'();:@&=+$,/?%#[]"),
                                             kCFStringEncodingUTF8));
    // 正規表現を生成
    NSRegularExpression *delivs =
    [NSRegularExpression regularExpressionWithPattern:@"%F3%A0%84%8[0-9|A-F]"
                                              options:0
                                                error:nil];
    // IVS 部分を削除
    escapedText = [delivs stringByReplacingMatchesInString:escapedText
                                                 options:0
                                                   range:NSMakeRange(0,escapedText.length)
                                            withTemplate:@""];
    // 元の文字列にデコード
    escapedText = (NSString *) CFBridgingRelease
    (CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                             (CFStringRef)escapedText,
                                                             CFSTR(""),
                                                             kCFStringEncodingUTF8));
    // 結果を返す
    return escapedText;
}

// 異体字セレクタ削除の初期設定は「削除しない」
NSString *deleteIvsFlag = @"NO";

// 異体字セレクタを削除するかしないかのグラグをトグルする
- (NSString *)toggleIvsFlag {
    if ([deleteIvsFlag isEqual: @"YES"]) {
        deleteIvsFlag = @"NO";
    } else {
        deleteIvsFlag = @"YES";
    }
    return deleteIvsFlag;
}

// メニューバーのチェックを付けたり取ったり
- (IBAction)toggleMenuIVS:(id)sender {
    if ([_deleteIvsFlag isEqual: @"YES"]) {
        _deleteIvsFlag = @"NO";
        [sender setState:NSOffState];
        [self toggleIvsFlag];
        //NSLog(@"menu-NO%@", _deleteIvsFlag);
    } else {
        _deleteIvsFlag = @"YES";
        [sender setState:NSOnState];
        [self toggleIvsFlag];
        //NSLog(@"menu-YES%@", _deleteIvsFlag);
    }
}

// 文字列を置換する(carをcdrへ)
- (NSString *)replaceStringCar:(NSString *)text {
    NSString *inputText = text;
    NSLog(@"%@", deleteIvsFlag);
    if ([deleteIvsFlag isEqual: @"YES"]) {
        inputText = [self deleteIVS:inputText];
        //NSLog(@"%@", deleteIvsFlag);
    }
    for (id cons in _innerDict) {
        inputText = [inputText stringByReplacingOccurrencesOfString:cons[0]
                                                         withString:cons[1]];
    }
    return inputText;
}

// 文字列を置換する(cdrをcarへ)
- (NSString *)replaceStringCdr:(NSString *)text {
    NSString *inputText = text;
    //NSLog(@"%@", deleteIvsFlag);
    if ([deleteIvsFlag isEqual: @"YES"]) {
        inputText = [self deleteIVS:inputText];
        //NSLog(@"%@", deleteIvsFlag);
    }
    for (id cons in _innerDict) {
        inputText = [inputText stringByReplacingOccurrencesOfString:cons[1]
                                                         withString:cons[0]];
    }
    return inputText;
}

// 入力エリアをクリアする
- (IBAction)ClearInput:(id)sender {
    _inputTextArea.string = @"";
}

// 変換の結果を入力へ移動する
- (IBAction)ResultToInput:(id)sender {
    _inputTextArea.string = _resultTextArea.string;
    _resultTextArea.string = @"";
}

// 旧字旧仮名を新字新仮名へ変換する
- (IBAction)TradOldToModernNew:(id)sender {
    NSString *tmp = @"";
    NSString *kanadict = [[NSBundle mainBundle] pathForResource:@"kana-jisyo" ofType:nil];
    NSString *kanjidict = [[NSBundle mainBundle] pathForResource:@"kanji-jisyo" ofType:nil];
    id fuga = [[MTOAppDelegate alloc] createDict:kanjidict];
    tmp = [fuga replaceStringCdr:_inputTextArea.string];
    id hoge = [[MTOAppDelegate alloc] createDict:kanadict];
    _resultTextArea.string = [hoge replaceStringCdr:tmp];
}

// 新字新仮名を旧字旧仮名へ変換する
- (IBAction)ModernNewToTradOld:(id)sender {
    NSString *tmp = @"";
    NSString *kanadict = [[NSBundle mainBundle] pathForResource:@"kana-jisyo" ofType:nil];
    NSString *kanjidict = [[NSBundle mainBundle] pathForResource:@"kanji-jisyo" ofType:nil];
    id hoge = [[MTOAppDelegate alloc] createDict:kanadict];
    tmp = [hoge replaceStringCar:_inputTextArea.string];
    id fuga = [[MTOAppDelegate alloc] createDict:kanjidict];
    _resultTextArea.string = [fuga replaceStringCar:tmp];
}

// 旧仮名を新仮名へ変換する
- (IBAction)TradToModern:(id)sender {
    NSString *kanadict = [[NSBundle mainBundle] pathForResource:@"kana-jisyo" ofType:nil];
    id mto = [[MTOAppDelegate alloc] createDict:kanadict];
    _resultTextArea.string = [mto replaceStringCdr:_inputTextArea.string];
//    [hoge clearDict];
}

// 新仮名を旧仮名へ変換する
- (IBAction)ModernToTrad:(id)sender {
    NSString *kanadict = [[NSBundle mainBundle] pathForResource:@"kana-jisyo" ofType:nil];
    id mto = [[MTOAppDelegate alloc] createDict:kanadict];
    _resultTextArea.string = [mto replaceStringCar:_inputTextArea.string];
//    [hoge clearDict];
}

// 旧漢字を新漢字へ変換する
- (IBAction)OldToNew:(id)sender {
    NSString *kanjidict = [[NSBundle mainBundle] pathForResource:@"kanji-jisyo" ofType:nil];
    id mto = [[MTOAppDelegate alloc] createDict:kanjidict];
    _resultTextArea.string = [mto replaceStringCdr:_inputTextArea.string];
//    [hoge clearDict];
}

// 新漢字を旧漢字へ変換する
- (IBAction)NewToOld:(id)sender {
    NSString *kanjidict = [[NSBundle mainBundle] pathForResource:@"kanji-jisyo" ofType:nil];
    id mto = [[MTOAppDelegate alloc] createDict:kanjidict];
    _resultTextArea.string = [mto replaceStringCar:_inputTextArea.string];
//    [hoge clearDict];
}

// 結果エリアのテキストをファイルに保存する
- (IBAction)writeToFile:(id)sender {
    NSSavePanel *sPanel = [NSSavePanel savePanel];

    [sPanel beginWithCompletionHandler:^(NSInteger result) {
    if(result == NSFileHandlingPanelOKButton) {
        // パスを取得
        NSURL *ofPath = [sPanel URL];
        [_resultTextArea.string writeToFile:
         [[[ofPath absoluteString] substringFromIndex:7]
          stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                 atomically:YES
                                   encoding:4
                                      error:NULL];

        //NSLog(@"保存したファイルは '%@'　ですか？", ofPath);

    } else if (result == NSFileHandlingPanelCancelButton) {
        //NSLog(@"キャンセルボタンを押しました");
    } else {
        //NSLog(@"エラーかも");
    }
    }];
}

// ファイルから文章を読み込む
- (IBAction)readFromFile:(id)sender {
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];

    [oPanel beginWithCompletionHandler:^(NSInteger result) {
    if (result == NSFileHandlingPanelOKButton) {
        // パスを取得
        NSURL *ifPath = [[oPanel URLs] objectAtIndex:0];

        NSError *errNotUtf8 = nil;
        NSString *utf8text = [NSString stringWithContentsOfFile:
                          [[[ifPath absoluteString] substringFromIndex:7]
                           stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                   encoding:NSUTF8StringEncoding
                                                   //encoding:NSISO2022JPStringEncoding
                                                      error:&errNotUtf8];
        if (errNotUtf8) {
            NSError *errNotSjis = nil;
            NSString *sjistext = [NSString stringWithContentsOfFile:
                              [[[ifPath absoluteString] substringFromIndex:7]
                               stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                       encoding:NSShiftJISStringEncoding
                                                          error:&errNotSjis];
            if (errNotSjis) {
                NSError *errNotEucJp = nil;
                NSString *euctext = [NSString stringWithContentsOfFile:
                                  [[[ifPath absoluteString] substringFromIndex:7]
                                   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                           encoding:NSJapaneseEUCStringEncoding
                                                              error:&errNotEucJp];
                if (errNotEucJp) {
                    _inputTextArea.string =
                    @"読み込めるのは\nUTF-8, Shift-JIS, EUC-JP\nのファイルだけじゃぁぁぁ（´・ω・｀）\n";
                } else {
                    _inputTextArea.string = euctext;
                }

            } else {
                _inputTextArea.string = sjistext;
            }

        } else {
            _inputTextArea.string = utf8text;
            //NSLog(@"選択したファイルは '%@'　ですか？", ifPath);
        }

    } else if (result == NSFileHandlingPanelCancelButton) {
        //NSLog(@"キャンセルボタンを押しました");
    } else {
        //NSLog(@"エラーかも");
    }
    }];

}

@end
