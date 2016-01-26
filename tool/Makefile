# Author: nakinor
# Created: 2016-01-25
# Revised: 2016-01-26

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

clean:
	find . -type file -perm 755 -exec rm -f {} ';'
#	rm mto-c mto-objc mto-go mto-mono mto-ccl mto-sbcl
