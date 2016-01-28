;-*- coding: utf-8 -*-
; Author: nakinor
; Created: 2016-01-24
; Revised: 2016-01-28

; Common Lisp での実装にチャレンジ
; Clozure CL 向け
;
; CCL では環境変数を利用し、またコンパイルするようにした。
; というか、スクリプト的に使うにはどうすればいいんだ？
;
; Usage:
;   ccl -l mto-ccl.lisp
;   ./mto-ccl options inputfile

; ライブラリの読み込み(これが無いと検索・置換ができない)
(load "~/quicklisp/setup.lisp")
(ql:quickload :cl-ppcre :silent t)

; パスの取得
(defparameter *mtodicdir* (getenv "MTODIC"))

; 辞書ファイルを指定
(defparameter *kana-jisyo*
  (concatenate 'string *mtodicdir* "/kana-jisyo"))
(defparameter *kanji-jisyo*
  (concatenate 'string *mtodicdir* "/kanji-jisyo"))

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
   ((equal "tradkana" (cadr *command-line-argument-list*))
    (make-jisyo *kana-jisyo*)
    (mto-replace-car (caddr *command-line-argument-list*)))
   ((equal "modernkana" (cadr *command-line-argument-list*))
    (make-jisyo *kana-jisyo*)
    (mto-replace-cdr (caddr *command-line-argument-list*)))
   ((equal "oldkanji" (cadr *command-line-argument-list*))
    (make-jisyo *kanji-jisyo*)
    (mto-replace-car (caddr *command-line-argument-list*)))
   ((equal "newkanji" (cadr *command-line-argument-list*))
    (make-jisyo *kanji-jisyo*)
    (mto-replace-cdr (caddr *command-line-argument-list*)))
   (t (format t "もしかしてオプションが違うかも？~%"))))

; 条件分岐(標準入力からの変換)
(defun replace-from-stdin ()
  (cond
   ((equal "tradkana" (cadr *command-line-argument-list*))
    (make-jisyo *kana-jisyo*)
    (mto-replace-stdin-car))
   ((equal "modernkana" (cadr *command-line-argument-list*))
    (make-jisyo *kana-jisyo*)
    (mto-replace-stdin-cdr))
   ((equal "oldkanji" (cadr *command-line-argument-list*))
    (make-jisyo *kanji-jisyo*)
    (mto-replace-stdin-car))
   ((equal "newkanji" (cadr *command-line-argument-list*))
    (make-jisyo *kanji-jisyo*)
    (mto-replace-stdin-cdr))
   (t (format t "もしかしてオプションが違うかも？~%"))))

; 使い方説明
(defun mto-usage ()
  (format t "Usage: ./mto-ccl options inputfile
options:
  tradkana    歴史的仮名使いに変換します
  modernkana  現代仮名使いに変換します
  oldkanji    旧字体に変換します
  newkanji    新字体に変換します~%"))

; メイン。まずはここからスタート
(defun main ()
  (cond ((< 3 (length *command-line-argument-list*)) (mto-usage))
        ((equal 3 (length *command-line-argument-list*))
         (replace-from-file))
        ((equal 2 (length *command-line-argument-list*))
         (replace-from-stdin))
        (t (mto-usage))))

(ccl:save-application
 "mto-ccl"
 :toplevel-function #'main
 :prepend-kernel t)

;(main)
