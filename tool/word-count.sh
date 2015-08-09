#!/bin/sh
#
# Author: nakinor
# Created: 2011-10-09
# Revised: 2015-04-13
#
# 辞書の途中に空白行があると実際の数とは合わなくなります

DICTDIR=`dirname ${0}`/../dict

kana_words=`grep -v '^;' $DICTDIR/kana-jisyo | wc -l`
kana_overlap=`sort $DICTDIR/kana-jisyo | cut -f1-2 -d' ' | uniq -d | sed -e '/\;/d'`

kanji_words=`grep -v '^;' $DICTDIR/kanji-jisyo | wc -l`
kanji_overlap=`sort $DICTDIR/kanji-jisyo | cut -f1-2 -d' ' | uniq -d | sed -e '/\;/d'`

check_words=`grep -v '^;' $DICTDIR/check-jisyo | wc -l`
check_overlap=`sort $DICTDIR/check-jisyo | cut -f1-2 -d' ' | uniq -d | sed -e '/\;/d'`

ruby_words=`grep -v '^;' $DICTDIR/ruby-jisyo | wc -l`
ruby_overlap=`sort $DICTDIR/ruby-jisyo | cut -f1-2 -d' ' | uniq -d | sed -e '/\;/d'`

kansai_words=`grep -v '^;' $DICTDIR/kansai-jisyo | wc -l`
kansai_overlap=`sort $DICTDIR/kansai-jisyo | cut -f1-2 -d' ' | uniq -d | sed -e '/\;/d'`

hangeul_words=`grep -v '^;' $DICTDIR/hangeul-jisyo | wc -l`
hangeul_overlap=`sort $DICTDIR/hangeul-jisyo | cut -f1-2 -d' ' | uniq -d | sed -e '/\;/d'`

printf '   辞書名    : 語彙数 | 重複しているもの(あれば表示される)\n'
printf 'かな辞書     : %6s | ' $kana_words
echo $kana_overlap
printf '漢字辞書     : %6s | ' $kanji_words
echo $kanji_overlap
printf '関西弁辞書   : %6s | ' $kansai_words
echo $kansai_overlap
printf 'ハングル辞書 : %6s | ' $hangeul_words
echo $hangeul_overlap
printf 'チェック用   : %6s | ' $check_words
echo $check_overlap
printf 'ルビ用       : %6s | ' $ruby_words
echo $ruby_overlap
echo '-----------------------'
printf 'かな漢字合計 : %6s | ' $(($kana_words + $kanji_words))
echo
echo
cat $DICTDIR/*-jisyo | grep -v '^;' | grep -v ' /' # 区切り文字チェック
cat $DICTDIR/*-jisyo | grep '^；' # コメント行の全角セミコロンチェック
cat $DICTDIR/*-jisyo | grep ' ；' # 全角セミコロンチェック。ちょっと苦しい
cat $DICTDIR/*-jisyo | grep '；「' # 全角セミコロンチェック。ちょっと苦しい
