//
//  main.m
//  mto
//
//  Created by nakinor on 2013/12/14.
//  Copyright (c) 2013年 nakinor. All rights reserved.
//

#include <Foundation/Foundation.h>
#import "MTODict.h"

void printUsage();

int main(int argc, const char * argv[]) {

    char *mtodir = getenv("MTODIR");
    NSString *dictfile;

    // 環境変数が設定されているかどうかチェック
    if (mtodir == NULL) {
        printf("%s", "環境変数 MTODIR を設定してください。\n");
        return 1;
    }

    // 引数処理
    if (argc == 1 || argc >= 4) {
      printUsage();
      return 1;
    }

    if (argc == 2) {
        NSString *henkanopt = [NSString stringWithCString:argv[1]
                                                 encoding:NSUTF8StringEncoding];

        if ([henkanopt isEqualToString:@"checkdictkana"]) {
          dictfile = [NSString stringWithFormat:@"%s%@",
                               mtodir, @"/dict/kana-jisyo"];
          id mtoinst = [[MTODict alloc] initWithDict:dictfile];
          [mtoinst printDict];
          //puts("checkdictkanaでした。");
        }
        else if ([henkanopt isEqualToString:@"checkdictkanji"]) {
          dictfile = [NSString stringWithFormat:@"%s%@",
                               mtodir, @"/dict/kanji-jisyo"];
          id mtoinst = [[MTODict alloc] initWithDict:dictfile];
          [mtoinst printDict];
          //puts("checkdictkanjiでした。");
        }
        else {
          puts("なんかへんやで");
          printUsage();
        }
    }

    if (argc == 3) {
      NSString *henkanopt = [NSString stringWithCString:argv[1]
                                               encoding: NSUTF8StringEncoding];
      if ([henkanopt isEqualToString:@"tradkana"]) {
        dictfile = [NSString stringWithFormat:@"%s%@",
                             mtodir, @"/dict/kana-jisyo"];
        id mtoinst = [[MTODict alloc] initWithDict:dictfile];
        [mtoinst replaceStringCar:
                   [NSString stringWithCString:argv[2]
                                      encoding:NSUTF8StringEncoding]];
        //puts("tradkanaでした。");
      }
      else if ([henkanopt isEqualToString:@"modernkana"]) {
        dictfile = [NSString stringWithFormat:@"%s%@",
                             mtodir, @"/dict/kana-jisyo"];
        id mtoinst = [[MTODict alloc] initWithDict:dictfile];
        [mtoinst replaceStringCdr:
                   [NSString stringWithCString:argv[2]
                                      encoding: NSUTF8StringEncoding]];
        //puts("modernkanaでした。");
      }
      else if ([henkanopt isEqualToString:@"oldkanji"]) {
        dictfile = [NSString stringWithFormat:@"%s%@",
                             mtodir, @"/dict/kanji-jisyo"];
        id mtoinst = [[MTODict alloc] initWithDict:dictfile];
        [mtoinst replaceStringCar:
                   [NSString stringWithCString:argv[2]
                                      encoding:NSUTF8StringEncoding]];
        //puts("oldkanjiでした。");
      }
      else if ([henkanopt isEqualToString:@"newkanji"]) {
        dictfile = [NSString stringWithFormat:@"%s%@",
                             mtodir, @"/dict/kanji-jisyo"];
        id mtoinst = [[MTODict alloc] initWithDict:dictfile];
        [mtoinst replaceStringCdr:
                   [NSString stringWithCString:argv[2]
                                      encoding:NSUTF8StringEncoding]];
        //puts("newkanjiでした。");
      }
      else {
        puts("オプションちゃうやんか");
        printUsage();
      }
	}
    return 0;
}

void printUsage() {
  puts("Usage: mto options filename");
  puts("options:");
  puts("  tradkana        歴史的仮名使いに変換します");
  puts("  modernkana      現代仮名使いに変換します");
  puts("  oldkanji        旧字体に変換します");
  puts("  newkanji        新字体に変換します");
  puts("  checkdictkana   かな辞書の要素数を表示します");
  puts("  checkdictkanji  漢字辞書の要素数を表示します");
}
