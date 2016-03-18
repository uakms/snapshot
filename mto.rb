#!/usr/local/bin/ruby -EUTF-8
# Author: nakinor
# Created: 2011-10-11
# Revised: 2016-01-28

# デフォルトの辞書の場所(絶対パスで指定した方が良い)
kana_jisyo  = ENV['MTODIC'] + "/kana-jisyo"
kanji_jisyo = ENV['MTODIC'] + "/kanji-jisyo"

# 変換を無視すべきクオートの種類
QUOTE_START_REGEXP = '<q>|<blockquote>|begin{quote}|begin{quotation}'
QUOTE_STOP_REGEXP  = '<\/q>|<\/blockquote>|end{quote}|end{quotation}'

# ハッシュを用意
$dic_arr = []

# 辞書から変換のための二次元配列を作成する
def create_dict(use_jisyo)
  File::open(use_jisyo, "r") { |file|
    while line = file.gets
      unless line =~ /^;.*|^$/                      # コメント行と空行を無視
        string = line.sub(/\s+;.*/, "").chomp("\n") # 備考を削除
        pairs = string.split(/\s* \/\s*/)           # ペアの配列にする
        $dic_arr << pairs                           # 配列の配列を作成
      end
    end
  }
end

# 読み込んだファイルの内容を置換する(すべてを変換する)
def replace_strings(use_dic_arr, input_file, opt)
  if FileTest.file?(ARGV[1])
    File::open(input_file, "r") { |file|
      text = file.read
      if opt == "car"
        use_dic_arr.each { |x| text.gsub!(x[0], x[1]) }
      else
        use_dic_arr.each { |x| text.gsub!(x[1], x[0]) }
      end
      print text
    }
  else
    puts "変換対象のファイルを開けません"
  end
end

## 標準入力から読み込んだものを置換する(すべてを変換する)
def replace_strings_stdin(use_dic_arr, opt)
  text = STDIN.read
  if opt == "car"
    use_dic_arr.each { |x| text.gsub!(x[0], x[1]) }
  else
    use_dic_arr.each { |x| text.gsub!(x[1], x[0]) }
  end
  print text
end

# 読み込んだファイルの内容を置換する(クオートされている部分は変換しない)
def replace_strings_noquote(use_dic_arr, input_file, opt)
  if FileTest.file?(ARGV[1])
    File::open(input_file, "r") { |file|
      flag = 0
      while line = file.gets
        if line =~ /#{QUOTE_START_REGEXP}/
          flag = 1
        elsif line =~ /#{QUOTE_STOP_REGEXP}/
          print line
          flag = 2
        end
        if flag == 0
          if opt == "car"
            use_dic_arr.each { |x| line.gsub!(x[0], x[1]) }
          else
            use_dic_arr.each { |x| line.gsub!(x[1], x[0]) }
          end
          print line
        elsif flag == 1
          print line
        elsif flag == 2
          flag = 0
        end
      end
    }
  else
    puts "変換対象のファイルを開けません"
  end
end

## 標準入力から読み込んだ内容を置換する(クオートされている部分は変換しない)
def replace_strings_stdin_noquote(use_dic_arr, opt)
  flag = 0
  while line = STDIN.gets
    if line =~ /#{QUOTE_START_REGEXP}/
      flag = 1
    elsif line =~ /#{QUOTE_STOP_REGEXP}/
      print line
      flag = 2
    end
    if flag == 0
      if opt == "car"
        use_dic_arr.each { |x| line.gsub!(x[0], x[1]) }
      else
        use_dic_arr.each { |x| line.gsub!(x[1], x[0]) }
      end
      print line
    elsif flag == 1
      print line
    elsif flag == 2
      flag = 0
    end
  end
end

# 使い方説明
def usage
  puts "Usage: #{File.basename($0)} options filename"
  puts "options:"
  puts "  tradkana      歴史的仮名使いに変換します"
  puts "  modernkana    現代仮名使いに変換します"
  puts "  oldkanji      旧字体に変換します"
  puts "  newkanji      新字体に変換します"
  puts "  nqtradkana    歴史的仮名使いに変換します(引用部分は無変換)"
  puts "  nqmodernkana  現代仮名使いに変換します(引用部分は無変換)"
  puts "  nqoldkanji    旧字体に変換します(引用部分は無変換)"
  puts "  nqnewkanji    新字体に変換します(引用部分は無変換)"
end

# 分岐処理とか
if ARGV.size == 0
  usage
elsif ARGV[0] =~ /^(trad|modern)kana$|^(old|new)kanji$/ ||
    ARGV[0] =~ /^nq(trad|modern)kana$|^nq(old|new)kanji$/
else
  puts "オプションが間違っています"
end
## ファイルの指定がなく、標準入力から読み込む場合の処理
if ARGV.size == 1
  case ARGV[0]
  when "tradkana"    # 歴史的仮名使いに変換
    create_dict(kana_jisyo)
    replace_strings_stdin($dic_arr, "car")
  when "modernkana"  # 現代仮名使い変換
    create_dict(kana_jisyo)
    replace_strings_stdin($dic_arr, "cdr")
  when "oldkanji"    # 旧字体に変換
    create_dict(kanji_jisyo)
    replace_strings_stdin($dic_arr, "car")
  when "newkanji"    # 新字体に変換
    create_dict(kanji_jisyo)
    replace_strings_stdin($dic_arr, "cdr")
  when "nqtradkana"    # 歴史的仮名使いに変換(引用部分は無変換)
    create_dict(kana_jisyo)
    replace_strings_stdin_noquote($dic_arr, "car")
  when "nqmodernkana"  # 現代仮名使い変換(引用部分は無変換)
    create_dict(kana_jisyo)
    replace_strings_stdin_noquote($dic_arr, "cdr")
  when "nqoldkanji"    # 旧字体に変換(引用部分は無変換)
    create_dict(kanji_jisyo)
    replace_strings_stdin_noquote($dic_arr, "car")
  when "nqnewkanji"    # 新字体に変換(引用部分は無変換)
    create_dict(kanji_jisyo)
    replace_strings_stdin_noquote($dic_arr, "cdr")
  end
end

# 指定されたファイルを読み込んで処理
## ファイルが指定されている時にそれが存在しているかどうかのチェック
if ARGV.size == 2
  case ARGV[0]
  when "tradkana"    # 歴史的仮名使いに変換
    create_dict(kana_jisyo)
    replace_strings($dic_arr, ARGV[1], "car")
  when "modernkana"  # 現代仮名使い変換
    create_dict(kana_jisyo)
    replace_strings($dic_arr, ARGV[1], "cdr")
  when "oldkanji"    # 旧字体に変換
    create_dict(kanji_jisyo)
    replace_strings($dic_arr, ARGV[1], "car")
  when "newkanji"    # 新字体に変換
    create_dict(kanji_jisyo)
    replace_strings($dic_arr, ARGV[1], "cdr")
  when "nqtradkana"    # 歴史的仮名使いに変換(引用部分は無変換)
    create_dict(kana_jisyo)
    replace_strings_noquote($dic_arr, ARGV[1], "car")
  when "nqmodernkana"  # 現代仮名使い変換(引用部分は無変換)
    create_dict(kana_jisyo)
    replace_strings_noquote($dic_arr, ARGV[1], "cdr")
  when "nqoldkanji"    # 旧字体に変換(引用部分は無変換)
    create_dict(kanji_jisyo)
    replace_strings_noquote($dic_arr, ARGV[1], "car")
  when "nqnewkanji"    # 新字体に変換(引用部分は無変換)
    create_dict(kanji_jisyo)
    replace_strings_noquote($dic_arr, ARGV[1], "cdr")
  else    # 使い方表示
    usage
  end
end
