#!/usr/local/bin/perl
# -*- coding: utf-8 -*-
#
# Author: nakinor
# Created: 2011-12-18
# Revised: 2012-07-24

# 辞書の場所を絶対パスで指定する
use FindBin;
my $kana_jisyo = "$FindBin::Bin/../dict/kana-jisyo";
my $kanji_jisyo = "$FindBin::Bin/../dict/kanji-jisyo";

# 配列を用意
@dict_arr = ();

# 辞書から変換のためのハッシュを作成する
sub create_hash{
  open (my $a_file, "<", $_[0])            # 引数が配列の番号で指定って...
    or die "$_[0] 辞書ファイルが見つかりませんでした";
  while (my $line = readline $a_file) {
    unless ($line =~ /^;.*$/) {            # コメント行でなければ...
      $line =~ s/\s+;.*//g;                # 備考を削除する
      $line =~ s/\n//g;                    # 改行を削除する
      @pairs = split(/\s* \/\s*/, $line);  # ペアの配列にする
      push @dict_arr, [ @pairs ];          # 配列の配列にする
    }
    else {}                                # コメント行は無視する
  }
}

# 読み込んだファイルの内容を置換する(すべてを変換する)
sub replace_strings{
  open (my $a_file, "<", $_[0])
    or die "$_[0] 変換対象のファイルが見つかりませんでした";
  read ($a_file, $text, -s $a_file);
  foreach $cons (@dict_arr) {
    if ($_[1] eq "car") {
      $text =~ s/@$@$cons[0]/@$@$cons[1]/g;  # ん、ん〜...
    }
    else {
      $text =~ s/@$@$cons[1]/@$@$cons[0]/g;
    }
  }
  print $text;
}

# 標準入力から読み込んだものを置換する(すべてを変換する)
sub replace_strings_stdin{
  @input = <STDIN>;
  my $text = join('', @input);
  foreach $cons (@dict_arr) {
    if ($_[0] eq "car") {
      $text =~ s/@$@$cons[0]/@$@$cons[1]/g;
    }
    else {
      $text =~ s/@$@$cons[1]/@$@$cons[0]/g;
    }
  }
  print $text;
}

# 読み込んだファイルの内容を置換する(クオート部分は無視する)
sub replace_strings_noquote{
  open (my $fh, "<", $_[0])
    or die "$_[0] 変換対象のファイルが見つかりませんでした";
  my $flag = 0;
  while (my $line = readline $fh) {
    if ($line =~ /<q>|<blockquote>|begin{quote}|begin{quotation}/) {
      $flag = 1;
    }
    elsif ($line =~ /<\/q>|<\/blockquote>|end{quote}|end{quotation}/) {
      print $line;
      $flag = 2;
    }
    if ($flag == 0) {
      foreach $cons (@dict_arr) {
        if ($_[1] eq "car") {
          $line =~ s/@$@$cons[0]/@$@$cons[1]/g;
        }
        else {
          $line =~ s/@$@$cons[1]/@$@$cons[0]/g;
        }
      }
      print $line;
    }
    elsif ($flag == 1) {
      print $line;
    }
    elsif ($flag == 2) {
      $flag = 0;
    }
  }
}

# 標準入力から読み込んだものを置換する(クオート部分は無視する)
sub replace_strings_stdin_noquote{
  my $flag = 0;
  while (my $line = <STDIN>) {
    if ($line =~ /<q>|<blockquote>|begin{quote}|begin{quotation}/) {
      $flag = 1;
    }
    elsif ($line =~ /<\/q>|<\/blockquote>|end{quote}|end{quotation}/) {
      print $line;
      $flag = 2;
    }
    if ($flag == 0) {
      foreach $cons (@dict_arr) {
        if ($_[0] eq "car") {
          $line =~ s/@$@$cons[0]/@$@$cons[1]/g;
        }
        else {
          $line =~ s/@$@$cons[1]/@$@$cons[0]/g;
        }
      }
      print $line;
    }
    elsif ($flag == 1) {
      print $line;
    }
    elsif ($flag == 2) {
      $flag = 0;
    }
  }
}

# 使い方説明
sub usage {
  print "Usage: $0 options filename\n";
  print "options:\n";
  print "  tradkana      歴史的仮名使いに変換します\n";
  print "  modernkana    現代仮名使いに変換します\n";
  print "  oldkanji      旧字体に変換します\n";
  print "  newkanji      新字体に変換します\n";
  print "  nqtradkana    歴史的仮名使いに変換します(引用部分は無変換)\n";
  print "  nqmodernkana  現代仮名使いに変換します(引用部分は無変換)\n";
  print "  nqoldkanji    旧字体に変換します(引用部分は無変換)\n";
  print "  nqnewkanji    新字体に変換します(引用部分は無変換)\n";
}

# 分岐処理
if (@ARGV == 0 | @ARGV > 2) {
  &usage;
  exit (0);
}

# 標準入力からのテキストを変換する
if (@ARGV == 1) {
  if (@ARGV[0] eq "tradkana") {
    &create_hash($kana_jisyo);
    &replace_strings_stdin("car");
    exit (0);
  }
  elsif  (@ARGV[0] eq "modernkana") {
    &create_hash($kana_jisyo);
    &replace_strings_stdin("cdr");
    exit (0);
  }
  elsif  (@ARGV[0] eq "oldkanji") {
    &create_hash($kanji_jisyo);
    &replace_strings_stdin("car");
    exit (0);
  }
  elsif  (@ARGV[0] eq "newkanji") {
    &create_hash($kanji_jisyo);
    &replace_strings_stdin("cdr");
    exit (0);
  }
  elsif (@ARGV[0] eq "nqtradkana") {
    &create_hash($kana_jisyo);
    &replace_strings_stdin_noquote("car");
    exit (0);
  }
  elsif  (@ARGV[0] eq "nqmodernkana") {
    &create_hash($kana_jisyo);
    &replace_strings_stdin_noquote("cdr");
    exit (0);
  }
  elsif  (@ARGV[0] eq "nqoldkanji") {
    &create_hash($kanji_jisyo);
    &replace_strings_stdin_noquote("car");
    exit (0);
  }
  elsif  (@ARGV[0] eq "nqnewkanji") {
    &create_hash($kanji_jisyo);
    &replace_strings_stdin_noquote("cdr");
    exit (0);
  }
  else {}
  &usage;
  exit (0);
}

# 既存のファイルのテキストを変換する
if (@ARGV == 2) {
  if (@ARGV[0] eq "tradkana") {
    &create_hash($kana_jisyo);
    &replace_strings(@ARGV[1], "car");
    exit (0);
  }
  elsif  (@ARGV[0] eq "modernkana") {
    &create_hash($kana_jisyo);
    &replace_strings(@ARGV[1], "cdr");
    exit (0);
  }
  elsif  (@ARGV[0] eq "oldkanji") {
    &create_hash($kanji_jisyo);
    &replace_strings(@ARGV[1], "car");
    exit (0);
  }
  elsif  (@ARGV[0] eq "newkanji") {
    &create_hash($kanji_jisyo);
    &replace_strings(@ARGV[1], "cdr");
    exit (0);
  }
  elsif (@ARGV[0] eq "nqtradkana") {
    &create_hash($kana_jisyo);
    &replace_strings_noquote(@ARGV[1], "car");
    exit (0);
  }
  elsif  (@ARGV[0] eq "nqmodernkana") {
    &create_hash($kana_jisyo);
    &replace_strings_noquote(@ARGV[1], "cdr");
    exit (0);
  }
  elsif  (@ARGV[0] eq "nqoldkanji") {
    &create_hash($kanji_jisyo);
    &replace_strings_noquote(@ARGV[1], "car");
    exit (0);
  }
  elsif  (@ARGV[0] eq "nqnewkanji") {
    &create_hash($kanji_jisyo);
    &replace_strings_noquote(@ARGV[1], "cdr");
    exit (0);
  }
  else {}
  &usage;
  exit (0);
}
