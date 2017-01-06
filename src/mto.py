# Author: nakinor
# Created: 2011-10-18
# Revised: 2016-01-28

# コマンドラインから引数を得るで
import os
import sys
import re

# Windows対策
import io
sys.stdin  = io.TextIOWrapper(sys.stdin.buffer, encoding='utf-8')
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# 辞書の場所を絶対パスで指定するで
kana_jisyo  = os.environ.get("MTODIC") + "/kana-jisyo"
kanji_jisyo = os.environ.get("MTODIC") + "/kanji-jisyo"

# 変換を無視すべきクオートの種類
beg_pattern = '<q>|<blockquote>|begin{quote}|begin{quotation}'
end_pattern = '</q>|</blockquote>|end{quote}|end{quotation}'

# 検索・置換ペアを一時的に収納する辞書を用意しとくで
dict_arr = []

# 辞書を作成する部品なんや
def create_dictionary(use_jisyo):
    ''' 辞書ファイルから疑似ハッシュ(辞書)を作成するんやで '''
    try:
        with open(use_jisyo, encoding='utf-8') as a_file:
            for a_line in a_file:
                if None != re.search('^;.*|^$', a_line): # 含まないとNoneを返す
                    pass
                else:
                    a_string = re.sub('\s+;.*', '', a_line).rstrip('\n') #削除
                    pairs = a_string.split(' /') # ペアの配列にするで
                    dict_arr.append(pairs)       # 二次元配列にするで
    except:
        print('きっと辞書が見付からんのやで')

# 置換をする部品なんや
def replace_strings(use_dict, opt):
    ''' 読み込んだファイルを置換するんや '''
    try:
        with open(sys.argv[2], encoding='utf-8') as a_file:
            text = a_file.read()
            for x in use_dict:
                if opt == "car":
                    text = text.replace(x[0], x[1])
                else:
                    text = text.replace(x[1], x[0])
            print('{0}'.format(text).rstrip('\n'))
    except:
        print('変換するファイルが見つからんのやけど...')

# 置換をする部品なんやその2
def replace_strings_stdin(use_dict, opt):
    ''' 標準入力から読み込んだやつを置換するんや '''
    try:
        text = sys.stdin.read()
        for x in use_dict:
            if opt == "car":
                text = text.replace(x[0], x[1])
            else:
                text = text.replace(x[1], x[0])
        print('{0}'.format(text).rstrip('\n'))
    except:
        print('UTF-8 以外の入力なんて知らんがな')

# 置換をする部品なんや(クオート部分は無視な)
def replace_strings_noquote(use_dict, opt):
    ''' 読み込んだファイルを置換するんや '''
    try:
        with open(sys.argv[2], encoding='utf-8') as a_file:
            flag = 0
            for text in a_file:
                if None != re.search(beg_pattern, text):
                    flag = 1
                elif None != re.search(end_pattern, text):
                    print('{0}'.format(text).rstrip('\n'))
                    flag = 2
                if flag == 0:
                    for x in use_dict:
                        if opt == "car":
                            text = text.replace(x[0], x[1])
                        else:
                            text = text.replace(x[1], x[0])
                    print('{0}'.format(text).rstrip('\n'))
                elif flag == 1:
                    print('{0}'.format(text).rstrip('\n'))
                elif flag == 2:
                    flag = 0
    except:
        print('変換するファイルが見つからんのやけど...')

# 置換をする部品なんや(クオート部分は無視な)その2
def replace_strings_stdin_noquote(use_dict, opt):
    ''' 標準入力から読み込んだやつを置換するんや '''
    try:
        flag = 0
        for text in sys.stdin.readlines():
            if None != re.search(beg_pattern, text):
                flag = 1
            elif None != re.search(end_pattern, text):
                print('{0}'.format(text).rstrip('\n'))
                flag = 2
            if flag == 0:
                for x in use_dict:
                    if opt == "car":
                        text = text.replace(x[0], x[1])
                    else:
                        text = text.replace(x[1], x[0])
                print('{0}'.format(text).rstrip('\n'))
            elif flag == 1:
                print('{0}'.format(text).rstrip('\n'))
            elif flag == 2:
                flag = 0
    except:
        print('UTF-8 以外の入力なんて知らんがな')

# あほな奴に説明せな
def usage():
    ''' 使い方説明 '''
    print('Usage: {0} options inputfile'.format(sys.argv[0]))
    print('options:')
    print('  tradkana      歴史的仮名使いに変換するで〜')
    print('  modernkana    現代仮名使いに変換するで〜')
    print('  oldkanji      旧字体に変換するで〜')
    print('  newkanji      新字体に変換するで〜')
    print('  nqtradkana    引用部分を無視して歴史的仮名使いに変換するで〜')
    print('  nqmodernkana  引用部分を無視して現代仮名使いに変換するで〜')
    print('  nqoldkanji    引用部分を無視して旧字体に変換するで〜')
    print('  nqnewkanji    引用部分を無視して新字体に変換するで〜')

# エラー処理とかな
if len(sys.argv) == 1:
    usage()
    quit()

if len(sys.argv) == 2:
    if "tradkana" == sys.argv[1]:
        create_dictionary(kana_jisyo)
        replace_strings_stdin(dict_arr, "car")
    elif "modernkana" == sys.argv[1]:
        create_dictionary(kana_jisyo)
        replace_strings_stdin(dict_arr, "cdr")
    elif "oldkanji" == sys.argv[1]:
        create_dictionary(kanji_jisyo)
        replace_strings_stdin(dict_arr, "car")
    elif "newkanji" == sys.argv[1]:
        create_dictionary(kanji_jisyo)
        replace_strings_stdin(dict_arr, "cdr")
    elif "nqtradkana" == sys.argv[1]:
        create_dictionary(kana_jisyo)
        replace_strings_stdin_noquote(dict_arr, "car")
    elif "nqmodernkana" == sys.argv[1]:
        create_dictionary(kana_jisyo)
        replace_strings_stdin_noquote(dict_arr, "cdr")
    elif "nqoldkanji" == sys.argv[1]:
        create_dictionary(kanji_jisyo)
        replace_strings_stdin_noquote(dict_arr, "car")
    elif "nqnewkanji" == sys.argv[1]:
        create_dictionary(kanji_jisyo)
        replace_strings_stdin_noquote(dict_arr, "cdr")
    else:
        print('んなあほなオプションあるかい')
        quit()

if len(sys.argv) == 3:
    if "tradkana" == sys.argv[1]:
        create_dictionary(kana_jisyo)
        replace_strings(dict_arr, "car")
    elif "modernkana" == sys.argv[1]:
        create_dictionary(kana_jisyo)
        replace_strings(dict_arr, "cdr")
    elif "oldkanji" == sys.argv[1]:
        create_dictionary(kanji_jisyo)
        replace_strings(dict_arr, "car")
    elif "newkanji" == sys.argv[1]:
        create_dictionary(kanji_jisyo)
        replace_strings(dict_arr, "cdr")
    elif "nqtradkana" == sys.argv[1]:
        create_dictionary(kana_jisyo)
        replace_strings_noquote(dict_arr, "car")
    elif "nqmodernkana" == sys.argv[1]:
        create_dictionary(kana_jisyo)
        replace_strings_noquote(dict_arr, "cdr")
    elif "nqoldkanji" == sys.argv[1]:
        create_dictionary(kanji_jisyo)
        replace_strings_noquote(dict_arr, "car")
    elif "nqnewkanji" == sys.argv[1]:
        create_dictionary(kanji_jisyo)
        replace_strings_noquote(dict_arr, "cdr")
    else:
        print('んなあほなオプションあるかい')
        quit()
