;-*- coding: utf-8 -*-
; Author: nakinor
; Created: 2013-11-23
; Revised: 2016-01-24

; Common Lisp での実装にチャレンジ
; SBCL 向け
;
; 辞書へのパスを環境変数を利用して取得するようにした
;
; Usage:
;   sbcl --script  mto-sbcl.lisp options inputfile
;
;
; バイナリにコンパイルする場合はバイナリにする部分のコメントを外して
;
; sbcl --noinform --no-sysinit --no-userinit --load mto-sbcl.lisp
; ./mto-sbcl options inputfile

; ライブラリの読み込み(これが無いと検索・置換ができない)
(load "~/quicklisp/setup.lisp")
(ql:quickload :cl-ppcre :silent t)

; パスの取得
(defparameter *mtorootdir* (sb-ext:posix-getenv "MTODIR"))

; 辞書ファイルを指定
(defparameter *kana-jisyo*
  (concatenate 'string *mtorootdir* "/dict/kana-jisyo"))
(defparameter *kanji-jisyo*
  (concatenate 'string *mtorootdir* "/dict/kanji-jisyo"))

; 連想リストを入れるための空リスト
(defparameter *dic-tmp* '())
(defparameter *dic* '())

; 辞書ファイルから連想リストを作成
(defun make-jisyo (jisyo)
  (with-open-file (in jisyo)
     (loop for line = (read-line in nil)
           while line
           do
           (unless (numberp (cl-ppcre:scan "^;.*|^$" line))
             (push
              (let ((ward
                     (cl-ppcre:split " /"
                       (cl-ppcre:regex-replace " ;.*" line ""))))
                (cons (car ward) (cadr ward)))
              *dic-tmp*)
             ) ;unless
           ) ;loop
     (setq *dic* (reverse *dic-tmp*))
     ) ;with-open-file
  )

; ファイルから一行ずつ読み込んで変換
(defun mto-replace-car (ifile)
  (with-open-file (in ifile)
     (loop for line = (read-line in nil)
           while line
           do
           (mapcar #'(lambda (x)
             (setq line
               (cl-ppcre:regex-replace-all (car x) line (cdr x)))) *dic*)
           (write-line line))))

(defun mto-replace-cdr (ifile)
  (with-open-file (in ifile)
     (loop for line = (read-line in nil)
           while line
           do
           (mapcar #'(lambda (x)
             (setq line
               (cl-ppcre:regex-replace-all (cdr x) line (car x)))) *dic*)
           (write-line line))))

; 標準入力から一行ずつ読み込んで変換
(defun mto-replace-stdin-car ()
  (loop for line = (read-line *standard-input* nil nil)
        while line
        do
        (mapcar #'(lambda (x)
          (setq line
            (cl-ppcre:regex-replace-all (car x) line (cdr x)))) *dic*)
        (write-line line)))

(defun mto-replace-stdin-cdr ()
  (loop for line = (read-line *standard-input* nil nil)
        while line
        do
        (mapcar #'(lambda (x)
          (setq line
            (cl-ppcre:regex-replace-all (cdr x) line (car x)))) *dic*)
        (write-line line)))

; 条件分岐(ファイルからの変換)
(defun replace-from-file ()
  (cond
   ((equal "tradkana" (cadr sb-ext:*posix-argv*))
    (make-jisyo *kana-jisyo*)
    (mto-replace-car (caddr sb-ext:*posix-argv*)))
   ((equal "modernkana" (cadr sb-ext:*posix-argv*))
    (make-jisyo *kana-jisyo*)
    (mto-replace-cdr (caddr sb-ext:*posix-argv*)))
   ((equal "oldkanji" (cadr sb-ext:*posix-argv*))
    (make-jisyo *kanji-jisyo*)
    (mto-replace-car (caddr sb-ext:*posix-argv*)))
   ((equal "newkanji" (cadr sb-ext:*posix-argv*))
    (make-jisyo *kanji-jisyo*)
    (mto-replace-cdr (caddr sb-ext:*posix-argv*)))
   (t (format t "もしかしてオプションが違うかも？~%"))))

; 条件分岐(標準入力からの変換)
(defun replace-from-stdin ()
  (cond
   ((equal "tradkana" (cadr sb-ext:*posix-argv*))
    (make-jisyo *kana-jisyo*)
    (mto-replace-stdin-car))
   ((equal "modernkana" (cadr sb-ext:*posix-argv*))
    (make-jisyo *kana-jisyo*)
    (mto-replace-stdin-cdr))
   ((equal "oldkanji" (cadr sb-ext:*posix-argv*))
    (make-jisyo *kanji-jisyo*)
    (mto-replace-stdin-car))
   ((equal "newkanji" (cadr sb-ext:*posix-argv*))
    (make-jisyo *kanji-jisyo*)
    (mto-replace-stdin-cdr))
   (t (format t "もしかしてオプションが違うかも？~%"))))

; 使い方説明
(defun mto-usage ()
  (format t "Usage: sbcl mto-sbcl.lisp options inputfile
options:
  tradkana    歴史的仮名使いに変換します
  modernkana  現代仮名使いに変換します
  oldkanji    旧字体に変換します
  newkanji    新字体に変換します~%"))

; メイン。まずはここからスタート
(defun main ()
  (cond ((< 3 (length sb-ext:*posix-argv*)) (mto-usage))
        ((equal 3 (length sb-ext:*posix-argv*))
         (replace-from-file))
        ((equal 2 (length sb-ext:*posix-argv*))
         (replace-from-stdin))
        (t (mto-usage))))

; バイナリにする場合はこの部分のコメントを外して (main) をコメントアウトする
; (sb-ext:save-lisp-and-die "mto-sbcl"
;                           :toplevel #'main
;                           :executable t)

(main)
