#!/usr/local/bin/lua
--[[
  Author: nakinor
  Created: 2011-12-22
  Revised: 2016-01-28
-- ]]

-- 辞書の場所を指定(絶対パスで指定する方がいい)
kana_jisyo = os.getenv("MTODIC") .. "/kana-jisyo"
kanji_jisyo = os.getenv("MTODIC") .. "/kanji-jisyo"

-- テーブルを用意
dic_table = {}

-- 辞書作成
function create_hash(use_jisyo)
   for a_line in io.lines(use_jisyo) do -- ファイルを開いて一行ずつ読み込む
      if string.find(a_line, "^;.*") then -- コメント行を削除
      elseif string.find(a_line, "^$") then -- 空行を削除
      else
         a_string = string.gsub(a_line, "%s+;.*", "") -- 備考を削除
         for key, value in string.gmatch(a_string, "(.+) /(.+)") do -- 分けて
            local pair = {key, value} -- 配列にして
            table.insert(dic_table ,pair) -- 配列の配列にする
         end
      end
   end
end

-- 置換(全て)
function replace_strings(use_dic, opt)
   fdr, err = io.open(arg[2], "r")
   if (not fdr) then
      print "指定されたファイルが見付かりません"
      return
   end
   for a_line in io.lines(arg[2]) do
      for k, rep_word in pairs(use_dic) do -- 配列のつもりが連想配列だった
         if opt == "car" then
            a_line = string.gsub(a_line, rep_word[1], rep_word[2]) -- 置換 car
         else
            a_line = string.gsub(a_line, rep_word[2], rep_word[1]) -- 置換 cdr
         end
      end
      print(a_line)
   end
end

-- 標準入力のデータを置換(全て)
function replace_strings_stdin(use_dic, opt)
   for a_line in io.lines() do -- ファイルを指定しないと標準入力から得る
      for k, rep_word in pairs(use_dic) do
         if opt == "car" then
            a_line = string.gsub(a_line, rep_word[1], rep_word[2])
         else
            a_line = string.gsub(a_line, rep_word[2], rep_word[1])
         end
      end
      print(a_line)
   end
end

-- 置換(クオートを無視)
-- 正規表現の | が無いらしい
function replace_strings_noquote(use_dic, opt)
   fdr, err = io.open(arg[2], "r")
   if (not fdr) then
      print "指定されたファイルが見付かりません"
      return
   end
   flag = 0
   for a_line in io.lines(arg[2]) do
      if string.find(a_line, "<p>") then
         flag = 1
      elseif string.find(a_line, "<blockquote>") then
         flag = 1
      elseif string.find(a_line, "begin{quote}") then
         flag = 1
      elseif string.find(a_line, "begin{quotation}") then
         flag = 1
      elseif string.find(a_line, "</p>") then
         print(a_line)
         flag = 2
      elseif string.find(a_line, "</blockquote>") then
         print(a_line)
         flag = 2
      elseif string.find(a_line, "end{quote}") then
         print(a_line)
         flag = 2
      elseif string.find(a_line, "end{quotation}") then
         print(a_line)
         flag = 2
      end
      if flag == 0 then
         for k, rep_word in pairs(use_dic) do
            if opt == "car" then
               a_line = string.gsub(a_line, rep_word[1], rep_word[2])
            else
               a_line = string.gsub(a_line, rep_word[2], rep_word[1])
            end
         end
         print(a_line)
      elseif flag == 1 then
         print (a_line)
      elseif flag == 2 then
         flag = 0
      end
   end
end

-- 標準入力のデータを置換(クオートを無視)
function replace_strings_stdin_noquote(use_dic, opt)
   flag = 0
   for a_line in io.lines(arg[2]) do
      if string.find(a_line, "<p>") then
         flag = 1
      elseif string.find(a_line, "<blockquote>") then
         flag = 1
      elseif string.find(a_line, "begin{quote}") then
         flag = 1
      elseif string.find(a_line, "begin{quotation}") then
         flag = 1
      elseif string.find(a_line, "</p>") then
         print(a_line)
         flag = 2
      elseif string.find(a_line, "</blockquote>") then
         print(a_line)
         flag = 2
      elseif string.find(a_line, "end{quote}") then
         print(a_line)
         flag = 2
      elseif string.find(a_line, "end{quotation}") then
         print(a_line)
         flag = 2
      end
      if flag == 0 then
         for k, rep_word in pairs(use_dic) do
            if opt == "car" then
               a_line = string.gsub(a_line, rep_word[1], rep_word[2])
            else
               a_line = string.gsub(a_line, rep_word[2], rep_word[1])
            end
         end
         print(a_line)
      elseif flag == 1 then
         print (a_line)
      elseif flag == 2 then
         flag = 0
      end
   end
end

-- 使い方
function usage()
   print ("Usage: " .. arg[0] .. " options filename")
   print "options:"
   print "  tradkana      歴史的仮名使いに変換します"
   print "  modernkana    現代仮名使いに変換します"
   print "  oldkanji      旧字体に変換します"
   print "  newkanji      新字体に変換します"
   print "  nqtradkana    歴史的仮名使いに変換します(引用部分は無変換)"
   print "  nqmodernkana  現代仮名使いに変換します(引用部分は無変換)"
   print "  nqoldkanji    旧字体に変換します(引用部分は無変換)"
   print "  nqnewkanji    新字体に変換します(引用部分は無変換)"
end

-- 分岐処理
if #arg == 0 then
   usage()
   return
elseif #arg > 2 then
   usage()
   return
end

-- 標準入力から
if #arg == 1 then
   if arg[1] == "tradkana" then
      create_hash(kana_jisyo)
      replace_strings_stdin(dic_table, "car")
      return
   elseif arg[1] == "modernkana" then
      create_hash(kana_jisyo)
      replace_strings_stdin(dic_table, "cdr")
      return
   elseif arg[1] == "oldkanji" then
      create_hash(kanji_jisyo)
      replace_strings_stdin(dic_table, "car")
      return
   elseif arg[1] == "newkanji" then
      create_hash(kanji_jisyo)
      replace_strings_stdin(dic_table, "cdr")
      return
   elseif arg[1] == "nqtradkana" then
      create_hash(kana_jisyo)
      replace_strings_stdin_noquote(dic_table, "car")
      return
   elseif arg[1] == "nqmodernkana" then
      create_hash(kana_jisyo)
      replace_strings_stdin_noquote(dic_table, "cdr")
      return
   elseif arg[1] == "nqoldkanji" then
      create_hash(kanji_jisyo)
      replace_strings_stdin_noquote(dic_table, "car")
      return
   elseif arg[1] == "nqnewkanji" then
      create_hash(kanji_jisyo)
      replace_strings_stdin_noquote(dic_table, "cdr")
      return
   else
      usage()
      return
   end
end

-- 指定したファイルから
if #arg == 2 then
   if arg[1] == "tradkana" then
      create_hash(kana_jisyo)
      replace_strings(dic_table, "car")
      return
   elseif arg[1] == "modernkana" then
      create_hash(kana_jisyo)
      replace_strings(dic_table, "cdr")
      return
   elseif arg[1] == "oldkanji" then
      create_hash(kanji_jisyo)
      replace_strings(dic_table, "car")
      return
   elseif arg[1] == "newkanji" then
      create_hash(kanji_jisyo)
      replace_strings(dic_table, "cdr")
      return
   elseif arg[1] == "nqtradkana" then
      create_hash(kana_jisyo)
      replace_strings_noquote(dic_table, "car")
      return
   elseif arg[1] == "nqmodernkana" then
      create_hash(kana_jisyo)
      replace_strings_noquote(dic_table, "cdr")
      return
   elseif arg[1] == "nqoldkanji" then
      create_hash(kanji_jisyo)
      replace_strings_noquote(dic_table, "car")
      return
   elseif arg[1] == "nqnewkanji" then
      create_hash(kanji_jisyo)
      replace_strings_noquote(dic_table, "cdr")
      return
   else
      usage()
      return
   end
end
