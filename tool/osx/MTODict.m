//
//  MTODict.m
//  mto
//
//  Created by nakinor on 2014/01/04.
//  Copyright (c) 2014年 nakinor. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "MTODict.h"

@interface MTODict()

@property NSMutableArray *innerDict;

@end


@implementation MTODict

- (id)initWithDict:(NSString *)dict {
  NSString *filePath = dict;
  NSString *text = [NSString stringWithContentsOfFile:filePath
                                             encoding:NSUTF8StringEncoding
                                                error:nil];
  // 辞書ファイルのコメント行を削除するための正規表現
  NSString *pat1 = @"^;.*|^$";
  // 辞書ファイルのコメント部分を削除するための正規表現
  NSString *pat2from = @"\\s+;.*";
  // コメント部分を削除(空)にするためのもの
  NSString *pat2to = @"";
  // 改行文字で区切って配列に格納する
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


- (void)printDict {
  printf("辞書の語彙は現在 %lu 語です。\n", [_innerDict count]);
}


- (void)replaceStringCar:(NSString *)file {
  NSError *error = nil;
  NSString *inputFilePath = file;
  NSString *inputText = [NSString stringWithContentsOfFile:inputFilePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
  if (error != nil){
    puts("辞書ファイルを開けんかったわ");
    return;
  }
  for(id cons in _innerDict){
    inputText = [inputText stringByReplacingOccurrencesOfString:cons[0]
                                                     withString:cons[1]];
  }
  printf("%s", [inputText UTF8String]);
}


- (void)replaceStringCdr:(NSString *)file {
  NSError *error = nil;
  NSString *inputFilePath = file;
  NSString *inputText = [NSString stringWithContentsOfFile:inputFilePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
  if (error != nil){
    puts("辞書ファイルを開けんかったわ");
    return;
  }
  for(id cons in _innerDict){
    inputText = [inputText stringByReplacingOccurrencesOfString:cons[1]
                                                     withString:cons[0]];
  }
  printf("%s", [inputText UTF8String]);
}

@end
