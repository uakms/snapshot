# Author: nakinor
# Created: 2018-04-14
# Revised: 2018-04-23

defmodule Mto do
  # 辞書へのパスを設定
  @kanajisyo  System.get_env("MTODIC") <> "/kana-jisyo"
  @kanjijisyo System.get_env("MTODIC") <> "/kanji-jisyo"

  # 一気にファイルを読み込む
  def readFile(text) do
    case File.read text do
      {:ok, file} -> _ = file
      {:error, _} -> IO.puts "ファイルを開けへん"
    end
  end

  # 一行ずつファイルを読み込んで内部辞書を作成する
  def createDict(jisyo) do
    {:ok, file} = File.read jisyo
    buf  = Regex.replace(~r/;.*/, file, "")        # コメント行・備考を削除
    tmp1 = Regex.replace(~r/ \//, buf, ",")        # 「単語組」を作る
    tmp2 = Regex.replace(~r/ +\n|\n+/, tmp1, ";")  # 改行を「単語組」の区切りに
    tmp3 = Regex.replace(~r/;+/, tmp2, ";")        # 複数の ';' を 1 つにする
    tmp4 = Regex.replace(~r/^;|;$/, tmp3, "")      # 余分な両末端の ';' を削除
    _ = pairList(String.split(tmp4, [";"]))
  end

  def pairList([head|tail]) do
    [String.split(head, [","]) | pairList(tail)]
  end

  def pairList([]) do
    []
  end

  # 文字列を置換する (car)
  def replaceTextCar(dict, text) do
    Enum.reduce(dict, text, fn([first|[second|_]]), str ->
      String.replace(str, first, second)
    end)
  end

  # 文字列を置換する (cdr)
  def replaceTextCdr(dict, text) do
    Enum.reduce(dict, text, fn([first|[second|_]]), str ->
      String.replace(str, second, first)
    end)
  end

  def process(:tradkana, inputtext) do
    innerdict = Mto.createDict(@kanajisyo)
    text = Mto.readFile(inputtext)
    IO.write Mto.replaceTextCar(innerdict, text)
  end

  def process(:modernkana, inputtext) do
    innerdict = Mto.createDict(@kanajisyo)
    text = Mto.readFile(inputtext)
    IO.write Mto.replaceTextCdr(innerdict, text)
  end

  def process(:oldkanji, inputtext) do
    innerdict = Mto.createDict(@kanjijisyo)
    text = Mto.readFile(inputtext)
    IO.write Mto.replaceTextCar(innerdict, text)
  end

  def process(:newkanji, inputtext) do
    innerdict = Mto.createDict(@kanjijisyo)
    text = Mto.readFile(inputtext)
    IO.write Mto.replaceTextCdr(innerdict, text)
  end

  # 引数は 2 つ与えられているがオプション名が間違っている場合
  def process(_, _) do
    IO.write """
    Usage: elixir mto.exs options filename
    options:
      tradkana      歴史的仮名使いに変換します
      modernkana    現代仮名使いに変換します
      oldkanji      旧字体に変換します
      newkanji      新字体に変換します
    """
  end

  def main(argv) do
    case length(argv) do
      2 ->
        [first|[second|_]] = argv
        process(String.to_atom(first), second)
      _ ->
        IO.write """
        Usage: elixir mto.exs options filename
        options:
          tradkana      歴史的仮名使いに変換します
          modernkana    現代仮名使いに変換します
          oldkanji      旧字体に変換します
          newkanji      新字体に変換します
        """
    end
  end
end

Mto.main(System.argv())
