# Author: nakinor
# Created: 2016-01-25
# Revised: 2016-12-30

.PHONY: all test clean
all: mto-c mto-cc mto-objc mto-go mto-mono mto-ccl mto-sbcl mto-swift

mto-c: mto.c
	clang -Ofast -o mto-c mto.c

mto-cc: mto.cc
	clang++ -Ofast -o mto-cc mto.cc

mto-objc: osx/main.m osx/MTODict.m
	clang -Ofast -o mto-objc -framework Foundation osx/main.m osx/MTODict.m

mto-swift: mto.swift
	xcrun --sdk `xcrun --show-sdk-path` swiftc -o mto-swift mto.swift

mto-go: mto.go
	go build -o mto-go mto.go

mto-mono: mto-mono.cs
	mcs -out:mto-mono mto-mono.cs

mto-ccl: mto-ccl.lisp
	@sed -e 's/unprocessed-command-line-arguments/command-line-argument-list/' mto-ccl.lisp > t1-mto-ccl.lisp
	@sed -e 's/;(mto-bin)/(mto-bin)/' t1-mto-ccl.lisp > t2-mto-ccl.lisp
	@sed -e 's/(main)/;(main)/' t2-mto-ccl.lisp > bin-mto-ccl.lisp
	ccl --no-init --load bin-mto-ccl.lisp
	@rm *-mto-ccl.lisp

mto-sbcl: mto-sbcl.lisp
	@sed -e 's/;(mto-bin)/(mto-bin)/' mto-sbcl.lisp > t1-mto-sbcl.lisp
	@sed -e 's/(main)/;(main)/' t1-mto-sbcl.lisp > bin-mto-sbcl.lisp
	sbcl --noinform --no-sysinit --no-userinit --load bin-mto-sbcl.lisp 1>/dev/null
	@rm *-mto-sbcl.lisp

test: test-gen \
	test-py \
	test-rb \
	test-mrb \
	test-pl \
	test-lua \
	test-gosh \
	test-node \
	test-php \
	test-mono \
	test-go \
	test-c \
	test-cc \
	test-ccl \
	test-sbcl \
	test-objc \
	test-swift

test-gen: test/seed
	@echo "Generate test files..."
	@cp test/seed test/ModernKanaNewKanji.ok
	@perl mto.pl tradkana test/seed > test/TradKanaNewKanji.ok
	@perl mto.pl oldkanji test/seed > test/ModernKanaOldKanji.ok

test-py:
	@echo "Python3 Test!"
	@sh test/test-diff.sh python3 mto.py

test-rb:
	@echo "Ruby Test!"
	@sh test/test-diff.sh ruby mto.rb

test-mrb:
	@echo "MRuby Test!"
	@sh test/test-diff.sh mruby mto.rb

test-pl:
	@echo "Perl Test!"
	@sh test/test-diff.sh perl mto.pl

test-lua:
	@echo "Lua Test!"
	@sh test/test-diff.sh lua mto.lua

test-gosh:
	@echo "Gauche Test!"
	@sh test/test-diff.sh gosh mto.scm

test-node:
	@echo "Node.js Test!"
	@sh test/test-diff.sh node mto-node.js

test-php:
	@echo "PHP Test!"
	@sh test/test-diff.sh php mto.php

test-mono: mto-mono
	@echo "Mono Test!"
	@sh test/test-diff.sh mono mto-mono

test-go: mto-go
	@echo "Go Test!"
	@sh test/test-diff.sh ./mto-go

test-c: mto-c
	@echo "C Test!"
	@sh test/test-diff.sh ./mto-c

test-cc: mto-cc
	@echo "CC Test!"
	@sh test/test-diff.sh ./mto-cc

test-ccl: mto-ccl
	@echo "Clozure CL Test!"
	@sh test/test-diff.sh ./mto-ccl

test-sbcl: mto-sbcl
	@echo "SBCL Test!"
	@sh test/test-diff.sh ./mto-sbcl

test-objc: mto-objc
	@echo "Objective-C Test!"
	@sh test/test-diff.sh ./mto-objc

test-swift: mto-swift
	@echo "Swift Test!"
	@sh test/test-diff.sh ./mto-swift

clean:
	find . -type file -perm 755 -exec rm -f {} ';'
	find . -type file -name '*.ok' -exec rm -f {} ';'
	find . -type file -name '*.out' -exec rm -f {} ';'
#	rm mto-c mto-objc mto-go mto-mono mto-ccl mto-sbcl
