#!/usr/local/bin/clisp
;-*- coding: utf-8 -*-
; Author: nakinor
; Created: 2012-06-05
; Revised: 2013-11-23

; Common Lisp での実装にチャレンジ
; asdf と cl-ppcre ライブラリが必要で、たぶん clisp 専用
;
; Usage: clisp mto-clisp.lisp options inputfile
;            or
;        cat inputfile | clisp mto-clisp.lisp options

; ライブラリの読み込み(これが無いと検索・置換ができない)
; quicklisp を使うようにした
(load "~/quicklisp/setup.lisp")
(ql:quickload :cl-ppcre)

; パスの取得
(setq apath (format nil "/~{~a~^/~}/"
                    (cdr (pathname-directory (truename "./")))))
(setq bpath (aref (ext:argv) 7))
(setq cpath (cl-ppcre:regex-replace apath bpath ""))
(setq dpath (concatenate 'string apath cpath))
(setq epath (format nil "/~{~a~^/~}/"
                    (cdr (pathname-directory dpath))))

; 辞書ファイルを指定
(setq kana-jisyo (concatenate 'string epath "../dict/kana-jisyo"))
(setq kanji-jisyo (concatenate 'string epath "../dict/kanji-jisyo"))

; 連想リストを入れるための空リスト
(setq *dic-tmp* '())
(setq *dic* '())

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
   ((equal "tradkana" (car ext:*args*))
    (make-jisyo kana-jisyo)
    (mto-replace-car (cadr ext:*args*)))
   ((equal "modernkana" (car ext:*args*))
    (make-jisyo kana-jisyo)
    (mto-replace-cdr (cadr ext:*args*)))
   ((equal "oldkanji" (car ext:*args*))
    (make-jisyo kanji-jisyo)
    (mto-replace-car (cadr ext:*args*)))
   ((equal "newkanji" (car ext:*args*))
    (make-jisyo kanji-jisyo)
    (mto-replace-cdr (cadr ext:*args*)))
   (t (format t "もしかしてオプションが違うかも？"))))

; 条件分岐(標準入力からの変換)
(defun replace-from-stdin ()
  (cond
   ((equal "tradkana" (car ext:*args*))
    (make-jisyo kana-jisyo)
    (mto-replace-stdin-car))
   ((equal "modernkana" (car ext:*args*))
    (make-jisyo kana-jisyo)
    (mto-replace-stdin-cdr))
   ((equal "oldkanji" (car ext:*args*))
    (make-jisyo kanji-jisyo)
    (mto-replace-stdin-car))
   ((equal "newkanji" (car ext:*args*))
    (make-jisyo kanji-jisyo)
    (mto-replace-stdin-cdr))
   (t (format t "もしかしてオプションが違うかも？"))))

; 使い方説明
(defun mto-usage ()
  (format t "Usage: clisp mto-clisp.lisp options inputfile
options:
  tradkana    歴史的仮名使いに変換します
  modernkana  現代仮名使いに変換します
  oldkanji    旧字体に変換します
  newkanji    新字体に変換します"))

; メイン。まずはここからスタート
(defun main ()
  (cond ((< 2 (length ext:*args*)) (mto-usage))
        ((equal 2 (length ext:*args*))
         (replace-from-file))
        ((equal 1 (length ext:*args*))
         (replace-from-stdin))
        (t (mto-usage))))

(main)
