/* Author: nakinor
 * Created: 2016-02-29
 * Revised: 2016-05-14
 */

#include <array>
#include <fstream>
#include <iostream>
#include <regex>
#include <string>

/* interface */
class MtoDict {
private:
  std::array<std::array<std::string, 2>, 6000> innerDict;
  int elemSize;

public:
  MtoDict(std::string dict);
  void strCarReplace(std::string ifilename);
  void strCdrReplace(std::string ifilename);
  void printDictSize();
};

/* implementation */
// オブジェクトを作成した時に内部辞書を作る
MtoDict::MtoDict(std::string dict) {
  elemSize = 0;
  std::string jisyopath = getenv("MTODIC");
  std::string jisyofile = jisyopath + "/" + dict;

  std::regex commentLinePattern("^;.*|^$");

  std::ifstream infile(jisyofile, std::ios::in);
  std::string str;

  if (infile.fail()) {
    std::cout << "辞書ファイルがみつからんのやけど？" << std::endl;
    exit(EXIT_FAILURE);
  }

  while (getline(infile, str)) {
    if (std::regex_match(str, commentLinePattern) == false) {
      // split が無い。C の sscanf 使うのはアレ
      std::string str2 = str.substr(0, str.find(" ;"));
      innerDict[elemSize][0] = str2.substr(0, str2.find(" /"));
      innerDict[elemSize][1] = str2.substr(str2.find(" /")+2, str2.find("\n"));
      elemSize++;
    }
  }
}

// ファイルの検索置換(新から旧)
void MtoDict::strCarReplace(std::string ifilename) {
  std::ifstream infile(ifilename, std::ios::in);
  std::string str;

  if(infile.fail()) {
    std::cout << "読み込むファイルがみつからんのやけど？" << std::endl;
    exit(EXIT_FAILURE);
  }

  while (getline(infile, str)) {
    for (int i = 0; i < elemSize; ++i) {
      std::string::size_type index(str.find(innerDict[i][0]));
      // if で判定すると一度しか置換されないのであった
      while (index != std::string::npos) {
        str.replace(str.find(innerDict[i][0]),
                    innerDict[i][0].size(),
                    innerDict[i][1]);
        index = str.find(innerDict[i][0], index + innerDict[i][1].size());
      }
    }
    std::cout << str.data() << std::endl;
  }
}

// ファイルの検索置換(旧から新)
void MtoDict::strCdrReplace(std::string ifilename) {
  std::ifstream infile(ifilename, std::ios::in);
  std::string str;

  if (infile.fail()) {
    std::cout << "読み込むファイルがみつからんのやけど？" << std::endl;
    exit(EXIT_FAILURE);
  }

  while (getline(infile, str)) {
    for (int i = 0; i < elemSize; ++i) {
      std::string::size_type index = str.find(innerDict[i][1]);
      // if で判定すると一度しか置換されないのであった
      while (index != std::string::npos) {
        str.replace(str.find(innerDict[i][1]),
                    innerDict[i][1].size(),
                    innerDict[i][0]);
        index = str.find(innerDict[i][1], index + innerDict[i][0].size());
      }
    }
    std::cout << str.data() << std::endl;
  }
}

// 辞書の要素数を表示する
void MtoDict::printDictSize() {
  //for (int i=0; i < elemSize; ++i) {
  //  std::cout << innerDict[i][0] + ", " + innerDict[i][1] << std::endl;
  //  }
  std::cout << "辞書の要素数：" + std::to_string(elemSize) << std::endl;
}

int main(int argc, char *argv[]) {
  if (argc == 3) {
    if (strcmp(argv[1], "tradkana") == 0) {
      MtoDict kana("kana-jisyo");
      kana.strCarReplace(argv[2]);
    } else if (strcmp(argv[1], "modernkana") == 0) {
      MtoDict kana("kana-jisyo");
      kana.strCdrReplace(argv[2]);
    } else if (strcmp(argv[1], "oldkanji") == 0) {
      MtoDict kanji("kanji-jisyo");
      kanji.strCarReplace(argv[2]);
    } else if (strcmp(argv[1], "newkanji") == 0) {
      MtoDict kanji("kanji-jisyo");
      kanji.strCdrReplace(argv[2]);
    } else {
      std::cout << "そんなオプションありまへん" << std::endl;
    }
  } else if (argc == 2) {
    if (strcmp(argv[1], "dickana") == 0) {
      MtoDict kana("kana-jisyo");
      kana.printDictSize();
    } else if (strcmp(argv[1], "dickanji") == 0) {
      MtoDict kanji("kanji-jisyo");
      kanji.printDictSize();
    } else {
      std::cout << "隠しコマンドあるで" << std::endl;
    }
  } else {
    std::cout << "Usage: mto options filename" << std::endl;
    std::cout << "options:" << std::endl;
    std::cout << "  tradkana    歴史的仮名使いに変換します" << std::endl;
    std::cout << "  modernkana  現代仮名使いに変換します" << std::endl;
    std::cout << "  oldkanji    旧字体に変換します" << std::endl;
    std::cout << "  newkanji    新字体に変換します" << std::endl;
  }
  return 0;
}
