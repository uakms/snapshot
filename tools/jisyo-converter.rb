#!/usr/local/bin/ruby -EUTF-8
# -*- coding: utf-8 -*-
#
# Author: nakinor
# Created: 2014-03-20
# Revised: 2016-01-29

require 'open-uri'

#MTODICT_SITE = "https://raw.githubusercontent.com/nakinor/mto/master"
MTODICT_SITE = ENV['MTODIC']
KANA_JISYO   = MTODICT_SITE + "/kana-jisyo"
KANJI_JISYO  = MTODICT_SITE + "/kanji-jisyo"
HANGEUL_JISYO  = MTODICT_SITE + "/hangeul-jisyo"

def split_comment(string)
  return string.sub("[", "[\"").gsub(/\|/, "\", \"").sub("]", "\"]")
end

def create_array_json(use_jisyo)
  tmp_arr = []
  open(use_jisyo, "r") { |io|
    while line = io.gets
      unless line =~ /^;.*|^$/
        string = line.sub(/(\s+;.*)/, "").chomp("\n")
        if $1 != nil
          commentString = $1.sub(/(\[.*\])/, "")
          #コメントの [hoge|fuga] 部分を取り出して次で使うためのダミー
        end
        comment = $1.to_s
        #comment が nil であっても .to_s をすると "" が得られてエラー回避
        if comment.size == 0
          comment = "[]"
        else
          comment = split_comment(comment)
        end
        string2 = string + " /" + comment
        elems = "\"" + string2.gsub(/\s* \//, "\", \"").sub(/\"\[/, "[")
        tmp_arr << elems
      end
    end
  }
  return tmp_arr
end

def output_array_json(dicarr, pref)
  tmp_arr = []
  dicarr.each { |x|
    tmp_arr << "[" + x + "]"
  }
  tmp_str = tmp_arr.join('_')
  return "var #{pref} \=\n[\n  " + tmp_str.gsub(/\]_/, "\],\n  ") + "\n]"
end

def create_dicarr(use_jisyo)
  tmp_arr = []
  open(use_jisyo, "r") { |io|
    while line = io.gets
      unless line =~ /^;.*|^$/
        string = line.sub(/\s+;.*/, "").chomp("\n")
        elems = string.split(/\s* \//)
        tmp_arr << elems
      end
    end
  }
  return tmp_arr
end

def output_json(dicarr)
  tmp_arr = []
  dicarr.each { |x|
    tmp_arr << "\"#{x[0]}\"" + ": " +  "\"#{x[1]}\""
  }
  tmp_str = tmp_arr.join(',')
  return "{\n  " + tmp_str.gsub(/\",/, "\",\n  ") + "\n}"
end

def output_json_t(dicarr, pref)
  tmp_arr = []
  dicarr.each { |x|
    tmp_arr << "\"#{x[1]}\"" + ": " +  "\"#{x[0]}\""
  }
  tmp_str = tmp_arr.join(',')
  return "var #{pref} \=\n{\n  " + tmp_str.gsub(/\",/, "\",\n  ") + "\n}"
end

def output_json_n(dicarr, pref)
  tmp_arr = []
  dicarr.each { |x|
    tmp_arr << "\"#{x[0]}\"" + ": " +  "\"#{x[1]}\""
  }
  tmp_str = tmp_arr.join(',')
  return "var #{pref} \=\n{\n  " + tmp_str.gsub(/\",/, "\",\n  ") + "\n}"
end

def output_tsv(dicarr)
  tmp_arr = []
  dicarr.each { |x|
    tmp_arr << "#{x[0]}" + "\t" +  "#{x[1]}"
  }
  return tmp_arr
end

def output_csv(dicarr)
  tmp_arr = []
  dicarr.each { |x|
    tmp_arr << "#{x[0]}" + "," +  "#{x[1]}"
  }
  return tmp_arr
end

def write_file(ofile, jisyo)
  File::open("#{ofile}", "w") { |f|
    if ofile =~ /(dic.*)|.json/
      case $1
      when "dic-kana.json"
        f.puts output_array_json(create_array_json(jisyo), "kanaArray")
      when "dic-kanji.json"
        f.puts output_array_json(create_array_json(jisyo), "kanjiArray")
      when "dic-hangeul.json"
        f.puts output_array_json(create_array_json(jisyo), "hanArray")
      else
        f.puts output_json(create_dicarr(jisyo))
      end
    elsif
      ofile =~ /csv/
      f.puts output_csv(create_dicarr(jisyo))
    elsif
      ofile =~ /tsv/
      f.puts output_tsv(create_dicarr(jisyo))
    else
      puts "知らんがな（´・ω・｀）"
      exit 1
    end
  }
end

def main()
  write_file("dic-kana.json", KANA_JISYO)
  write_file("dic-kanji.json", KANJI_JISYO)
  write_file("dic-hangeul.json", HANGEUL_JISYO)
  # write_file("kana-jisyo.json", KANA_JISYO)
  # write_file("kanji-jisyo.json", KANJI_JISYO)
  # write_file("kana-jisyo.csv", KANA_JISYO)
  # write_file("kanji-jisyo.csv", KANJI_JISYO)
  # write_file("kana-jisyo.tsv", KANA_JISYO)
  # write_file("kanji-jisyo.tsv", KANJI_JISYO)
end

main()
