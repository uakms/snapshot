;;-*- coding: utf-8 -*-
;;
;; Author: nakinor
;; Created: 2011-10-12
;; Revised: 2016-01-28
;;
; Scheme でも mto を実装してみるプロジェクト
; Gauche で用意されているライブラリを利用しているので gosh 専用です

(use file.util) ; file-is-readable? 等を使う
(use srfi-98) ; sys-getenv ではなく get-environment-variable を使う

; 読み込む辞書ファイルへのパス(環境変数を利用)
(define kanajisyo
  (string-append (get-environment-variable "MTODIC") "/kana-jisyo"))
(define kanjijisyo
  (string-append (get-environment-variable "MTODIC") "/kanji-jisyo"))

; 作成したコンスセル集(連想リスト)を収納するための空リストを用意
(define dic-tmp '()) ;できれば使いたくないのだけど局所変数がわからないので
(define dic '()) ;これが変換辞書の本体になる

; 辞書ファイルを読み込んで連想リスト(辞書)を作成する
(define (make-jisyo jisyo) ;読み込む辞書の名前を引数に取る関数の定義を開始
  (with-input-from-file jisyo ;ファイルを開いて読み込む
    (lambda () ;読み込んだファイルに対して何かをする(thunk)
      (port-for-each ;一行読み込んで...
       (lambda (str) ;その行(str)に対して次の処理をさせる(->コンスセル作成)
         (unless (rxmatch
                  (string->regexp "^;.*|^$")
                  str) ;コメント行と空行を無視して...
                 (push! dic-tmp ;次々と辞書に追加していく
                        (let ((ward ;局所変数を用意して...
                               (string-split ;文字列を単語に分けて...
                                (regexp-replace
                                 (string->regexp "[[:space:]];.*")
                                 str "") " /")))
                          (cons (car ward) (cadr ward)))))) ;コンスセル作成
       read-line) ;一行読み込んで...の部分はここで終了
      ) ;ファイルに対して何か...の部分を終了
    ) ;ファイルを(自動的に)閉じる
  (set! dic (reverse dic-tmp)) ;順番が逆になってしまうので戻す
  ) ;関数定義の終了

;; ファイルから一行ずつ読み込んで処理(car->cdr)
(define (mto-replace-car ifile) ;変換するファイルを引数に取る関数宣言
  (with-input-from-file ifile ;ファイルを開いて読み込む
    (lambda () ;何か処理をさせる(0を返すダミーみたいなもの。サンク)
      (port-for-each ;一行読み込んで...
       (lambda (str) ;その行に対して置換処理をさせる
         (for-each (lambda (x) ;コンスセルから要素の全てに対して...
                     (set! str ;置換されたものを上書き
                           (regexp-replace-all (car x) str (cdr x)) ;置換する
                           ) ;end set!
                     ) ;end lambda
                   dic) ;end for-each
         (print str) ;破壊的に置換した行を表示
         ) ;end lambda
       read-line) ;end port-for-each
      ) ;end lambda
    ) ;end with
  ) ;end define

;; ファイルから一行ずつ読み込んで処理(cdr->car)
(define (mto-replace-cdr ifile)
  (with-input-from-file ifile
    (lambda ()
      (port-for-each
       (lambda (str)
         (for-each (lambda (x)
                     (set! str (regexp-replace-all (cdr x) str (car x)))) dic)
         (print str)) read-line))))

;; 標準入力から一行ずつ読み込んで処理(car->cdr)
(define (mto-replace-stdin-car)
  (port-for-each
   (lambda (str)
     (for-each (lambda (x)
                 (set! str (regexp-replace-all (car x) str (cdr x)))) dic)
     (print str))
   read-line))

;; 標準入力から一行ずつ読み込んで処理(cdr->car)
(define (mto-replace-stdin-cdr)
  (port-for-each
   (lambda (str)
     (for-each (lambda (x)
                 (set! str (regexp-replace-all (cdr x) str (car x)))) dic)
     (print str))
   read-line))

;; コマンドラインから引数を受けて分岐処理をする
; ファイルが指定されている時の分岐処理
(define (replace-from-file args)
  (if (file-is-readable? (caddr args)) ;ファイルの存在をチェック
      (case (string->symbol (car (cdr args))) ;引数をシンボルに変更しておく
        ((tradkana) (begin (make-jisyo kanajisyo) ;新仮名から旧仮名へ変換
                           (mto-replace-car (caddr args))))
        ((modernkana) (begin (make-jisyo kanajisyo) ;旧仮名から新仮名へ変換
                             (mto-replace-cdr (caddr args))))
        ((oldkanji) (begin (make-jisyo kanjijisyo) ;新字体から旧字体へ変換
                           (mto-replace-car (caddr args))))
        ((newkanji) (begin (make-jisyo kanjijisyo) ;旧字体から新字体へ変換
                           (mto-replace-cdr (caddr args))))
        (else (print "オプションが違っているのかも"))) ;これは内側の case
      (print "ファイルが見付からないのかも"))) ;これは外側の if

; ファイルが指定されていない場合(標準入力)の分岐処理
(define (replace-from-stdin args)
  (case (string->symbol (car (cdr args)))
    ((tradkana) (begin (make-jisyo kanajisyo)
                       (mto-replace-stdin-car)))
    ((modernkana) (begin (make-jisyo kanajisyo)
                         (mto-replace-stdin-cdr)))
    ((oldkanji) (begin (make-jisyo kanjijisyo)
                       (mto-replace-stdin-car)))
    ((newkanji) (begin (make-jisyo kanjijisyo)
                       (mto-replace-stdin-cdr)))
    (else (print "オプションが違っているのかも(stdin)"))))

; エラーを表示する(display を使うと表示に時間がかかるので print で)
(define (display-usage)
  (print "Usage: gosh mto.scm options inputfile
options:
  tradkana    歴史的仮名使いに変換します
  modernkana  現代仮名使いに変換します
  oldkanji    旧字体に変換します
  newkanji    新字体に変換します"))

;; メイン部分
(define (main args) ;ここからスタートする
  (cond ((eq? 3 (length args)) (replace-from-file args))
        ((eq? 2 (length args)) (replace-from-stdin args))
        (else (display-usage)))
  0)

;; メモ
; 行をリストにして読み込む
;   (call-with-input-file checkjisyo port->string-list)
;
; ファイル全体を一気に読み込む
;   (call-with-input-file checkjisyo port->string)
;
; `map` は取り出す順番が処理系に依存するので、先頭から取り出す順番を確実にする
; ためには `for-each` を使うとのこと。ただし、副作用ではなく戻り値が欲しい場合は
; map を使わないとダメ。例えばリストのそれぞれの要素に対して 2 乗したリストを得
; たい時は map を使う。
