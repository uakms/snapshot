# Author: nakinor
# Created: 2014-03-20
# Revised: 2016-03-02

MTODICT_DIR   = ENV['MTODIC']
KANA_JISYO    = MTODICT_DIR + "/kana-jisyo"
KANJI_JISYO   = MTODICT_DIR + "/kanji-jisyo"
HANGEUL_JISYO = MTODICT_DIR + "/hangeul-jisyo"

def split_comment(string)
  return string.sub("[", "[\"").gsub(/\|/, "\", \"").sub("]", "\"]")
end


############################################################################
# 新型の JSON を出力するクラス
class MtoNewDict
  #二次元配列を作成する
  def initialize(use_jisyo)
    @dicarr = []
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
          @dicarr << elems
        end
      end
    }
  end

  # 新型の JSON を出力する
  # 例  ["そう", "さう", []],
  #     ["り", "리", ["理", "里", "李", "裏", "裡"]],
  def output_json(pref="pref")
    tmp_arr = []
    @dicarr.each { |x|
      tmp_arr << "[" + x + "]"
    }
    tmp_str = tmp_arr.join('_')
    return "var #{pref} \=\n[\n  " + tmp_str.gsub(/\]_/, "\],\n  ") + "\n]"
  end
end


############################################################################
# 旧型の各種フォーマットを出力するクラス
class MtoDict
  # 二次元配列を作成する
  def initialize(use_jisyo)
    @dicarr = []
    open(use_jisyo, "r") { |io|
      while line = io.gets
        unless line =~ /^;.*|^$/
          string = line.sub(/\s+;.*/, "").chomp("\n")
          elems = string.split(/\s* \//)
          @dicarr << elems
        end
      end
    }
  end

  # JSON 形式で出力するメソッド
  # 例  flag が 'r' 以外の時  "そう": "さう",
  #     flag が 'r'     の時  "さう": "そう",
  def output_json(flag="n")
    tmp_arr = []
    if flag != "r"
      @dicarr.each { |x| tmp_arr << "\"#{x[0]}\"" + ": " + "\"#{x[1]}\""}
    else
      @dicarr.each { |x| tmp_arr << "\"#{x[1]}\"" + ": " + "\"#{x[0]}\""}
    end
    tmp_str = tmp_arr.join(',')
    return "{\n  " + tmp_str.gsub(/\",/, "\",\n  ") + "\n}"
  end

  # プレフィックス付きの JSON 形式で出力するメソッド
  # 例  flag が 'r' 以外の時  "そう": "さう",
  #     flag が 'r'     の時  "さう": "そう",
  def output_pref_json(pref, flag="n")
    tmp_arr = []
    if flag != "r"
      @dicarr.each { |x| tmp_arr << "\"#{x[0]}\"" + ": " + "\"#{x[1]}\""}
    else
      @dicarr.each { |x| tmp_arr << "\"#{x[1]}\"" + ": " + "\"#{x[0]}\""}
    end
    tmp_str = tmp_arr.join(',')
    return "var #{pref} \=\n{\n  " + tmp_str.gsub(/\",/, "\",\n  ") + "\n}"
  end

  # TSV 形式で出力するメソッド
  # 例  flag が 'r' 以外の時  そう	さう
  #     flag が 'r'     の時  さう	そう
  def output_tsv(flag="n")
    tmp_arr = []
    if flag != "r"
      @dicarr.each { |x| tmp_arr << "#{x[0]}" + "\t" + "#{x[1]}" }
    else
      @dicarr.each { |x| tmp_arr << "#{x[1]}" + "\t" + "#{x[0]}" }
    end
    return tmp_arr
  end

  # CSV 形式で出力するメソッド
  # 例  flag が 'r' 以外の時  そう,さう
  #     flag が 'r'     の時  さう,そう
  def output_csv(flag="n")
    tmp_arr = []
    if flag != "r"
      @dicarr.each { |x| tmp_arr << "#{x[0]}" + "," + "#{x[1]}"}
    else
      @dicarr.each { |x| tmp_arr << "#{x[1]}" + "," + "#{x[0]}"}
    end
    return tmp_arr
  end

  # YAML 形式で出力するメソッド
  # 例  flag が 'r' 以外の時  そう: [さう]
  #     flag が 'r'     の時  さう: [そう]
  def output_yml(flag="n")
    tmp_arr = []
    if flag != "r"
      @dicarr.each { |x| tmp_arr << "#{x[0]}" + ": [" + "#{x[1]}" + "]"}
    else
      @dicarr.each { |x| tmp_arr << "#{x[1]}" + ": [" + "#{x[0]}" + "]"}
    end
    return tmp_arr
  end
end


############################################################################
# 標準出力ではなくファイルに直接書き込む
def write_file(ofile, data)
  File::open("#{ofile}", "w") { |f|
    f.puts data
  }
end


############################################################################
def main()
  kana_data = MtoNewDict.new(KANA_JISYO).output_json("kanaArray")
  write_file("dic-kana.json", kana_data)

  kanji_data = MtoNewDict.new(KANJI_JISYO).output_json("kanjiArray")
  write_file("dic-kanji.json", kanji_data)

  hange_data = MtoNewDict.new(HANGEUL_JISYO).output_json("hanArray")
  write_file("dic-hangeul.json", hange_data)
end

main()

# puts MtoDict.new(KANA_JISYO).output_json("n")
# puts MtoDict.new(KANA_JISYO).output_json("r")
# puts MtoDict.new(KANJI_JISYO).output_json("n")
# puts MtoDict.new(KANJI_JISYO).output_json("r")

# puts MtoDict.new(KANA_JISYO).output_pref_json("kana","n")
# puts MtoDict.new(KANA_JISYO).output_pref_json("kana", "r")
# puts MtoDict.new(KANJI_JISYO).output_pref_json("kanji", "n")
# puts MtoDict.new(KANJI_JISYO).output_pref_json("kanji", "r")

# puts MtoDict.new(KANA_JISYO).output_csv("n")
# puts MtoDict.new(KANA_JISYO).output_csv("r")
# puts MtoDict.new(KANJI_JISYO).output_csv("n")
# puts MtoDict.new(KANJI_JISYO).output_csv("r")

# puts MtoDict.new(KANA_JISYO).output_tsv("n")
# puts MtoDict.new(KANA_JISYO).output_tsv("r")
# puts MtoDict.new(KANJI_JISYO).output_tsv("n")
# puts MtoDict.new(KANJI_JISYO).output_tsv("r")

# puts MtoDict.new(KANA_JISYO).output_yml("n")  # nvcheck 仮名の旧から新向け
# puts MtoDict.new(KANA_JISYO).output_yml("r")  # nvcheck 仮名の新から旧向け
# puts MtoDict.new(KANJI_JISYO).output_yml("n") # nvcheck 漢字の旧から新向け
# puts MtoDict.new(KANJI_JISYO).output_yml("r") # nvcheck 漢字の新から旧向け
