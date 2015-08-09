/* Author: nakinor
 * Created: 2013-12-06
 * Revised: 2013-12-15
 */

package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"regexp"
	"strings"
	"os"
)

var (
	kanajisyo string = os.Getenv("MTODIR") + "/dict/kana-jisyo"
	kanjijisyo string = os.Getenv("MTODIR") + "/dict/kanji-jisyo"
	dicarr = [][]string{}
)

func DictCreator(jisyo string) {
	ifile, _ := os.Open(jisyo)
	scanner := bufio.NewScanner(ifile)
	re := regexp.MustCompile("[\t\n\f\r ]+;.*")

	for scanner.Scan() {
		line, _ := regexp.MatchString("^;.*|^$", scanner.Text())
		if line == false {
			str := re.ReplaceAllString(scanner.Text(), "")
			pairs := regexp.MustCompile(" /").Split(str, 2)
			dicarr = append(dicarr, pairs)
		}
	}
}

func StringCarReplacer(ifile string) {
	content, err := ioutil.ReadFile(ifile)
	if err != nil {
		fmt.Println("ファイルを開けなかったの（´・ω・｀）")
	}
	str := string(content)
	for _, element := range dicarr {
		str = strings.Replace(str, element[0], element[1], -1)
	}
	fmt.Printf("%s", str)
}

func StringCdrReplacer(ifile string) {
	content, err := ioutil.ReadFile(ifile)
	if err != nil {
		fmt.Println("ファイルを開けなかったの（´・ω・｀）")
	}
	str := string(content)
	for _, element := range dicarr {
		str = strings.Replace(str, element[1], element[0], -1)
	}
	fmt.Printf("%s", str)
}

func StdinStringCarReplacer() {
	content, _ := ioutil.ReadAll(os.Stdin)
	str := string(content)
	for _, element := range dicarr {
		str = strings.Replace(str, element[0], element[1], -1)
	}
	fmt.Printf("%s", str)
}

func StdinStringCdrReplacer() {
	content, _ := ioutil.ReadAll(os.Stdin)
	str := string(content)
	for _, element := range dicarr {
		str = strings.Replace(str, element[1], element[0], -1)
	}
	fmt.Printf("%s", str)
}

func UsagePrinter() {
	fmt.Println("Usage: go run mto.go options filename")
	fmt.Println("options:")
	fmt.Println("  tradkana    歴史的仮名使いに変換します")
	fmt.Println("  modernkana  現代仮名使いに変換します")
	fmt.Println("  oldkanji    旧字体に変換します")
	fmt.Println("  newkanji    新字体に変換します")
}

func ArgumentParser() {
	if len(os.Args) == 1 || len(os.Args) >=4 {
		UsagePrinter()
		return
	}

	if len(os.Args) == 2 {
		switch {
		case os.Args[1] == "tradkana" :
			DictCreator(kanajisyo)
			StdinStringCarReplacer()
			return
		case os.Args[1] == "modernkana" :
			DictCreator(kanajisyo)
			StdinStringCdrReplacer()
			return
		case os.Args[1] == "oldkanji" :
			DictCreator(kanjijisyo)
			StdinStringCarReplacer()
			return
		case os.Args[1] == "newkanji" :
			DictCreator(kanajisyo)
			StdinStringCdrReplacer()
			return
		}
		UsagePrinter()
		return
	}

	if len(os.Args) == 3 {
		switch {
		case os.Args[1] == "tradkana" :
			DictCreator(kanajisyo)
			StringCarReplacer(os.Args[2])
			return
		case os.Args[1] == "modernkana" :
			DictCreator(kanajisyo)
			StringCdrReplacer(os.Args[2])
			return
		case os.Args[1] == "oldkanji" :
			DictCreator(kanjijisyo)
			StringCarReplacer(os.Args[2])
			return
		case os.Args[1] == "newkanji" :
			DictCreator(kanajisyo)
			StringCdrReplacer(os.Args[2])
			return
		}
		UsagePrinter()
		return
	}
}

func main() {
	if os.Getenv("MTODIR") == "" {
		fmt.Println("MTODIR を環境変数に設定してください。")
		fmt.Println("例：export MTODIR=\"/Users/path/to/mto\"")
		return
	}
	ArgumentParser()
}
