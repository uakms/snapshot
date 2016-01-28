/* vim:ts=4:
 * Author: nakinor
 * Created: 2015-04-09
 * Revised: 2015-05-01
 */

package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
)

var (
	reComment = regexp.MustCompile("^;.*|^$")         //コメント行
	reNote    = regexp.MustCompile("[\t\n\f\r ]+;.*") //備考
	reSepa    = regexp.MustCompile(" /")              //辞書の区切り文字
)

func CreateJsonDict(jisyo string) []string {
	jsonDictArr := []string{}
	ifile, err := os.Open(jisyo)
	if err != nil {
		fmt.Println("ファイルを読み込めませんでした")
		os.Exit(0)
	}
	defer ifile.Close()
	scanner := bufio.NewScanner(ifile)

	for scanner.Scan() {
		commentedLine := reComment.MatchString(scanner.Text())

		if commentedLine == false {
			mbody := reNote.ReplaceAllString(scanner.Text(), "")
			supl := reNote.FindStringSubmatch(scanner.Text())
			suplstr := ""

			if len(supl) != 0 {
				reSplmnt := regexp.MustCompile("\\[(.*)\\]")
				supl2 := reSplmnt.FindAllStringSubmatch(supl[0], -1)

				if len(supl2) != 0 {
					reSubSep := regexp.MustCompile("\\|")
					suplstr = "[\"" +
						reSubSep.ReplaceAllString(supl2[0][1], "\", \"") + "\"]"
				} else {
					suplstr = "[]"
				}
			} else {
				suplstr = "[]"
			}

			mainstr := reSepa.ReplaceAllString(mbody, "\", \"")
			elem := "[\"" + mainstr + "\", " + suplstr + "]"
			jsonDictArr = append(jsonDictArr, elem)
		}
	}
	return jsonDictArr
}

func OutputJsonDict(jsonDictArr []string, pref string, fname string) {
	ofile, err := os.Create(fname)
	if err != nil {
		fmt.Println("ファイルを書き込めませんでした")
		os.Exit(0)
	}
	defer ofile.Close()
	writer := bufio.NewWriter(ofile)
	fmt.Fprint(writer, "var "+pref+" =\n[\n")
	for i := 0; i < len(jsonDictArr)-1; i++ {
		fmt.Fprint(writer, "  "+jsonDictArr[i]+",\n")
	}
	fmt.Fprint(writer, "  "+jsonDictArr[len(jsonDictArr)-1]+"\n]\n")
	writer.Flush()
	return
}

func DictChecker(jisyo string) {
	var (
		extractArr   = []string{}
		reIncomplete = regexp.MustCompile("　|；| /.\\S*;|^.\\S*/")
	)

	ifile, err := os.Open(jisyo)
	if err != nil {
		fmt.Println("ファイルを読み込めませんでした")
		os.Exit(0)
	}
	defer ifile.Close()
	scanner := bufio.NewScanner(ifile)

	for scanner.Scan() {
		commentedLine := reComment.MatchString(scanner.Text())
		if commentedLine == false {
			fault := reIncomplete.MatchString(scanner.Text())
			if fault == true {
				extractArr = append(extractArr, scanner.Text())
			}
		}
	}

	if len(extractArr) == 0 {
		fmt.Println("(^_^) 辞書の書式に問題はなさそうです")
	} else {
		fmt.Println("(>_<) 次の行に問題がありそうです")
		for _, element := range extractArr {
			fmt.Printf("%s\n", element)
		}
	}
	return
}

func DictDuplicateChecker(mainDictArr [][]string) {
	duplicatedarr := [][]string{}
	for i := 0; i < len(mainDictArr); i++ {
		if mainDictArr[i][0] == mainDictArr[i][1] {
			duplicatedarr = append(duplicatedarr, mainDictArr[i])
		}
		for j := i + 1; j < len(mainDictArr); j++ {
			if len(mainDictArr[i]) != 1 {
				if (mainDictArr[i][0] == mainDictArr[j][0]) &&
					(mainDictArr[i][1] == mainDictArr[j][1]) {
					duplicatedarr = append(duplicatedarr, mainDictArr[i])
				}
			}
		}
	}
	if len(duplicatedarr) == 0 {
		fmt.Println("\n(^_^) 辞書に重複はなさそうです")
	} else {
		fmt.Println("\n(>_<) 次の単語に重複登録、もしくは key と value が同じ状態のものがありそうです")
		for _, dups := range duplicatedarr {
			fmt.Printf("%v\n", dups[0])
		}
	}
	return
}

func DictCreator(jisyo string) [][]string {
	mainDictArr := [][]string{}
	ifile, err := os.Open(jisyo)
	if err != nil {
		fmt.Println("ファイルを読み込めませんでした")
		os.Exit(0)
	}
	defer ifile.Close()
	scanner := bufio.NewScanner(ifile)

	for scanner.Scan() {
		commentedLine := reComment.MatchString(scanner.Text())
		if commentedLine == false {
			str := reNote.ReplaceAllString(scanner.Text(), "")
			pair := reSepa.Split(str, 2)
			mainDictArr = append(mainDictArr, pair)
		}
	}
	return mainDictArr
}

func OutputDict(mainDictArr [][]string, flag string) {
	for _, element := range mainDictArr {
		if flag == "normal" {
			fmt.Printf("%s %s\n", element[0], element[1])
		} else if flag == "reverse" {
			fmt.Printf("%s %s\n", element[1], element[0])
		}
	}
	return
}

func UsagePrinter() {
	fmt.Println("Usage: go run conv.go option inputfile")
	fmt.Println("  option:")
	fmt.Println("          -n [normal] カラム1 カラム2 の順で出力")
	fmt.Println("          -r [revese] カラム2 カラム1 の順で出力")
	fmt.Println("          -j [json]   JSON形式でファイルに出力")
	fmt.Println("          -c [check]  辞書をチェック")
	fmt.Println("          -l [length] 要素数を出力")
	return
}

func ArgumentParser() {
	if len(os.Args) <= 2 || len(os.Args) >= 4 {
		UsagePrinter()
		return
	}

	if len(os.Args) == 3 {
		jisyo := os.Args[2]
		mainArr := DictCreator(jisyo)

		switch {
		case os.Args[1] == "-n":
			OutputDict(mainArr, "normal")
			return
		case os.Args[1] == "-r":
			OutputDict(mainArr, "reverse")
			return
		case os.Args[1] == "-l":
			fmt.Println(len(mainArr))
			return
		case os.Args[1] == "-c":
			DictChecker(jisyo)
			DictDuplicateChecker(mainArr)
			return
		case os.Args[1] == "-j":
			re := regexp.MustCompile(".*/(.*)-jisyo")
			matched := re.FindStringSubmatch(jisyo)
			jsonArr := CreateJsonDict(jisyo)

			if matched[1] == "hangeul" {
				OutputJsonDict(jsonArr, "hanArray", "dic-hangeul.json")
			} else if matched[1] == "kana" {
				OutputJsonDict(jsonArr, "kanaArray", "dic-kana.json")
			} else if matched[1] == "kanji" {
				OutputJsonDict(jsonArr, "kanjiArray", "dic-kanji.json")
			} else {
				fmt.Println("JSON出力に対応している辞書は")
				fmt.Println("[kana, kanji, hangeul] のみです。")
			}
			return
			//case os.Args[1] == "-t" :
			//	fmt.Println(len(DictCreator(jisyo)))
			//	return
		}
		UsagePrinter()
		return
	}
}

func main() {
	ArgumentParser()
	return
}
