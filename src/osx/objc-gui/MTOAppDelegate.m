//
//  MTOAppDelegate.m
//  CocoaMto
//
//  Created by nakinor on 2014/01/08.
//  Copyright (c) 2014年, 2015年 nakinor. All rights reserved.
//

#import "MTOAppDelegate.h"

@implementation MTOAppDelegate

- (void)applicationDidFinishLaunching:
    (NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [_inputTextArea setFont:
                      [NSFont fontWithName:@"Hiragino Maru Gothic ProN W4"
                                      size:14.0]];
    [_resultTextArea setFont:
                       [NSFont fontWithName:@"Hiragino Maru Gothic ProN W4"
                                       size:14.0]];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:
    (NSApplication *)theApplication
{
    return YES;
}

- (id)createDict:(NSString *)dict {
    NSString *filePath = dict;
    NSString *text = [NSString stringWithContentsOfFile:filePath
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    NSString *pat1 = @"^;.*|^$";
    NSString *pat2from = @"\\s+;.*";
    NSString *pat2to = @"";
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    NSMutableArray *tmpdict = [NSMutableArray array];

    NSRegularExpression *regexp1 =
    [NSRegularExpression regularExpressionWithPattern:pat1
                                              options:0
                                                error:nil];

    for (NSString *line in lines) {
        NSTextCheckingResult *match =
        [regexp1 firstMatchInString:line
                            options:0
                              range:NSMakeRange(0, line.length)];

        if(match.numberOfRanges){
        }
        else {
            NSRegularExpression *regexp2 =
            [NSRegularExpression regularExpressionWithPattern:pat2from
                                                      options:0
                                                        error:nil];
            NSString *result =
            [regexp2 stringByReplacingMatchesInString:line
                                              options:0
                                                range:NSMakeRange(0,line.length)
                                         withTemplate:pat2to];
            [tmpdict addObject:[result componentsSeparatedByString:@" /"]];
        }
    }
    _innerDict = tmpdict;
    return self;
}

- (NSString *)replaceStringCar:(NSString *)text {
    NSString *inputText = text;
    for(id cons in _innerDict){
        inputText = [inputText stringByReplacingOccurrencesOfString:cons[0]
                                                         withString:cons[1]];
    }
    return inputText;
}

- (NSString *)replaceStringCdr:(NSString *)text {
    NSString *inputText = text;
    for(id cons in _innerDict){
        inputText = [inputText stringByReplacingOccurrencesOfString:cons[1]
                                                         withString:cons[0]];
    }
    return inputText;
}

- (IBAction)ClearInput:(id)sender {
    _inputTextArea.string = @"";
}

- (IBAction)ResultToInput:(id)sender {
    _inputTextArea.string = _resultTextArea.string;
    _resultTextArea.string = @"";
}

- (IBAction)TradOldToModernNew:(id)sender {
    NSString *tmp = @"";
    NSString *kanadict = [[NSBundle mainBundle] pathForResource:@"kana-jisyo"
                                                         ofType:nil];
    NSString *kanjidict = [[NSBundle mainBundle] pathForResource:@"kanji-jisyo"
                                                          ofType:nil];
    id mtob = [[MTOAppDelegate alloc] createDict:kanjidict];
    tmp = [mtob replaceStringCdr:_inputTextArea.string];
    id mtoa = [[MTOAppDelegate alloc] createDict:kanadict];
    _resultTextArea.string = [mtoa replaceStringCdr:tmp];
}

- (IBAction)ModernNewToTradOld:(id)sender {
    NSString *tmp = @"";
    NSString *kanadict = [[NSBundle mainBundle] pathForResource:@"kana-jisyo"
                                                         ofType:nil];
    NSString *kanjidict = [[NSBundle mainBundle] pathForResource:@"kanji-jisyo"
                                                          ofType:nil];
    id mtoa = [[MTOAppDelegate alloc] createDict:kanadict];
    tmp = [mtoa replaceStringCar:_inputTextArea.string];
    id mtob = [[MTOAppDelegate alloc] createDict:kanjidict];
    _resultTextArea.string = [mtob replaceStringCar:tmp];
}

- (IBAction)TradToModern:(id)sender {
    NSString *kanadict = [[NSBundle mainBundle] pathForResource:@"kana-jisyo"
                                                         ofType:nil];
    id mto = [[MTOAppDelegate alloc] createDict:kanadict];
    _resultTextArea.string = [mto replaceStringCdr:_inputTextArea.string];
}

- (IBAction)ModernToTrad:(id)sender {
    NSString *kanadict = [[NSBundle mainBundle] pathForResource:@"kana-jisyo"
                                                         ofType:nil];
    id mto = [[MTOAppDelegate alloc] createDict:kanadict];
    _resultTextArea.string = [mto replaceStringCar:_inputTextArea.string];
}

- (IBAction)OldToNew:(id)sender {
    NSString *kanjidict = [[NSBundle mainBundle] pathForResource:@"kanji-jisyo"
                                                          ofType:nil];
    id mto = [[MTOAppDelegate alloc] createDict:kanjidict];
    _resultTextArea.string = [mto replaceStringCdr:_inputTextArea.string];
}

- (IBAction)NewToOld:(id)sender {
    NSString *kanjidict = [[NSBundle mainBundle] pathForResource:@"kanji-jisyo"
                                                          ofType:nil];
    id mto = [[MTOAppDelegate alloc] createDict:kanjidict];
    _resultTextArea.string = [mto replaceStringCar:_inputTextArea.string];
}

- (IBAction)writeToFile:(id)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    NSArray *allowedFileTypes =
      [NSArray arrayWithObjects:@"txt",@"'TEXT'",nil];
    [savePanel setAllowedFileTypes:allowedFileTypes];
    NSInteger pressedButton = [savePanel runModal];
    if(pressedButton == NSOKButton)
    {
      NSURL *filePath = [savePanel URL];
      [_resultTextArea.string writeToFile:
                        [[filePath absoluteString] substringFromIndex:7]
                               atomically:YES
                                 encoding:4
                                    error:NULL];
    }
    else {
    }
}

- (IBAction)readFromFile:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSArray *allowedFileTypes =
      [NSArray arrayWithObjects:@"txt",@"'TEXT'",nil];
    [openPanel setAllowedFileTypes:allowedFileTypes];
    NSInteger pressedButton = [openPanel runModal];
    if(pressedButton == NSOKButton)
    {
      NSURL *filePath = [openPanel URL];
      NSString *text =
        [NSString stringWithContentsOfFile:
                    [[filePath absoluteString] substringFromIndex:7]
                                  encoding:NSUTF8StringEncoding
                                     error:nil];
      _inputTextArea.string = text;
    }
    else {
    }
}

@end
