# Author: nakinor
# Created: 2016-01-25
# Revised: 2016-01-28

all: mto-c mto-objc mto-go mto-mono mto-ccl mto-sbcl

mto-c: mto.c
	clang -Ofast -o mto-c mto.c

mto-objc: osx/main.m osx/MTODict.m
	clang -Ofast -o mto-objc -framework Foundation osx/main.m osx/MTODict.m

mto-go: mto.go
	go build -o mto-go mto.go

mto-mono: mto-mono.cs
	mcs -out:mto-mono mto-mono.cs

mto-ccl: mto-ccl.lisp
	dx86cl64 --no-init --load mto-ccl.lisp

mto-sbcl: mto-sbcl.lisp
	@sed -e 's/^;.*(sb-ext/(sb-ext/' mto-sbcl.lisp > t1-mto-sbcl.lisp
	@sed -e 's/^;.*:toplevel/:toplevel/' t1-mto-sbcl.lisp > t2-mto-sbcl.lisp
	@sed -e 's/^;.*:executable/:executable/' t2-mto-sbcl.lisp > t3-mto-sbcl.lisp
	@sed -e 's/(main)/;(main)/' t3-mto-sbcl.lisp > bin-mto-sbcl.lisp
	sbcl --noinform --no-sysinit --no-userinit --load bin-mto-sbcl.lisp 1>/dev/null
	@rm *-mto-sbcl.lisp 

.PHONY: test

test: test-gen \
	test-py \
	test-rb \
	test-pl \
	test-lua \
	test-gosh \
	test-node \
	test-mono \
	test-go \
	test-c \
	test-ccl \
	test-sbcl \
	test-objc

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

test-mono: mto-mono
	@echo "Mono Test!"
	@sh test/test-diff.sh mono mto-mono

test-go: mto-go
	@echo "Go Test!"
	@sh test/test-diff.sh ./mto-go

test-c: mto-c
	@echo "C Test!"
	@sh test/test-diff.sh ./mto-c

test-ccl: mto-ccl
	@echo "Cluzure CL Test!"
	@sh test/test-diff.sh ./mto-ccl

test-sbcl: mto-sbcl
	@echo "SBCL Test!"
	@sh test/test-diff.sh ./mto-sbcl

test-objc: mto-objc
	@echo "Objective-C Test!"
	@sh test/test-diff.sh ./mto-objc

clean:
	find . -type file -perm 755 -exec rm -f {} ';'
	find . -type file -name '*.ok' -exec rm -f {} ';'
	find . -type file -name '*.out' -exec rm -f {} ';'
#	rm mto-c mto-objc mto-go mto-mono mto-ccl mto-sbcl
