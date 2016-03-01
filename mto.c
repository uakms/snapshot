/* Author: nakinor
 * Created: 2015-09-22
 * Revised: 2016-02-29
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <regex.h>

//#define PRINT_DICT
#define MAX_ELEM 4500  /* 作成する辞書の最大要素数 */
#define MAX_LINE 256   /* 外部辞書の一行の長さ x 文字の UTF-8 バイト数 */
                       /* 一行 80x3 で 256 バイトあれば十分かな？ */
#define TMP_LINE 128   /* 備考を除いた要素になりうる部分のバイト数 */

#define MAX_STRG 4096  /* 開いたファイルをどのバイト数ずつ読み込むのか */

char innerDict[MAX_ELEM][2][64];
int elemSize = 0;      /* 内部辞書の要素数を保持する変数 */

int createDict(char *jisyo);
int strCdrReplace(char *ifile);
int strCarReplace(char *ifile);
int strgsub(char *buf, char *car, char *cdr);


int main(int argc, char *argv[]) {
  char kanajisyo[256];                  /* パスの長さってどのくらいになる？*/
  strcpy(kanajisyo, getenv("MTODIC"));  /* 環境変数は実行時にわかるのでここ */
  strcat(kanajisyo, "/kana-jisyo");     /* 簡単にディープコピーしたいわ*/
  char kanjijisyo[256];
  strcpy(kanjijisyo, getenv("MTODIC"));
  strcat(kanjijisyo, "/kanji-jisyo");

  if (argc != 1) {
    if (strcmp(argv[1], "tradkana") == 0) {
      createDict(kanajisyo);
      strCarReplace(argv[2]);
    } else if  (strcmp(argv[1], "modernkana") == 0) {
      createDict(kanajisyo);
      strCdrReplace(argv[2]);
    } else if  (strcmp(argv[1], "oldkanji") == 0) {
      createDict(kanjijisyo);
      strCarReplace(argv[2]);
    } else if  (strcmp(argv[1], "newkanji") == 0) {
      createDict(kanjijisyo);
      strCdrReplace(argv[2]);
    } else {
      puts("そんなオプションありまへん");
    }
  } else {
    puts("Usage: mto options filename");
    puts("options:");
    puts("  tradkana    歴史的仮名使いに変換します");
    puts("  modernkana  現代仮名使いに変換します");
    puts("  oldkanji    旧字体に変換します");
    puts("  newkanji    新字体に変換します");
  }

  return 0;
}


int strCdrReplace(char *ifile) {
  FILE *fp;
  char str[MAX_STRG];

  if ((fp = fopen(ifile, "r")) == NULL) {
    printf("ファイルをひらけなかった（´・ω・｀）\n");
    exit(EXIT_FAILURE);
  }
  while (fgets(str, MAX_STRG, fp) != NULL) {
    int i;
    for (i = 0; i < elemSize; ++i) {
      strgsub(str, innerDict[i][1], innerDict[i][0]);
    }
    printf("%s", str);
  }
  return 0;
}


int strCarReplace(char *ifile) {
  FILE *fp;
  char str[MAX_STRG];

  if ((fp = fopen(ifile, "r")) == NULL) {
    printf("ファイルをひらけなかった（´・ω・｀）\n");
    exit(EXIT_FAILURE);
  }
  while (fgets(str, MAX_STRG, fp) != NULL) {
    int i;
    for (i = 0; i < elemSize; ++i) {
      strgsub(str, innerDict[i][0], innerDict[i][1]);
    }
    printf("%s", str);
  }
  return 0;
}


/* 外部ファイルを読み込んで内部辞書 (innerDict) を作成する */
int createDict(char *jisyo) {
  FILE *fp;
  char str[MAX_LINE];

  /* コメント行をマッチさせるための正規表現を生成 */
  static char *commentLinePattern = "^;.*|^$";
  regex_t clpReg;
  regcomp(&clpReg, commentLinePattern, REG_EXTENDED|REG_NOSUB);

  if ((fp = fopen(jisyo, "r")) == NULL) {
    printf("辞書ファイルをひらけなかった（´・ω・｀）\n");
    exit(EXIT_FAILURE);
  }

  while (fgets(str, MAX_LINE, fp) != NULL) {
    /* コメント行かどうか調べる */
    if (regexec(&clpReg, str, 0, NULL, 0) == REG_NOMATCH) {
      /* コメント行でなければ配列に入れて辞書にする */
      sscanf(str, "%s /%s",
             &*innerDict[elemSize][0],  /* &* を付けるとうまくいくぞ */
             &*innerDict[elemSize][1]);
      elemSize++;
    }
  }
  fclose(fp);         /* ファイルを閉じる */
  regfree(&clpReg);   /* 正規表現を開放 */

#ifdef PRINT_DICT
  for (int i = 0; i < elemSize; ++i) {
    printf("%s %s\n", innerDict[i][0], innerDict[i][1]);
  }
  printf("%d\n", elemSize);
#endif

  return 0;  /* 配列を返すわけではないので。グローバル配列だもん */
}


int strgsub(char *str, char *car, char *cdr) {
  char *ptr;
  char tmp[MAX_STRG];

  while ((ptr = strstr(str, car)) != NULL) {
    *ptr = '\0';        /* car で見かった部分に '\0' を挿入して文字列を切る*/
    ptr += strlen(car); /* 後ろの文字列を得るためにポインタをずらす */
    strcpy(tmp, ptr);   /* cdr を挿入すると消えちゃうので tmp に保存しておく */
    strcat(str, cdr);   /* cdr を挿入する */
    strcat(str, tmp);   /* tmp に退避していた文字列を結合する */
  }                     /* ポインタ渡しなので実引数 str が変更される */
  return 0;
}
