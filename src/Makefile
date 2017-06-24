# Author: nakinor
# Created: 2016-01-25
# Revised: 2017-06-24

.PHONY: all test bench clean

BINDIR    = bin
TEST_PRG  = test/test-diff.sh
BENCH_PRG = bench/benchmark.rb

# Section: Build the binary files
all: $(BINDIR)/mto-c \
	$(BINDIR)/mto-cc \
	$(BINDIR)/mto-objc \
	$(BINDIR)/mto-go \
	$(BINDIR)/mto-mono \
	$(BINDIR)/mto-ccl \
	$(BINDIR)/mto-sbcl \
	$(BINDIR)/mto-swift

$(BINDIR)/mto-c: mto.c
	clang -Ofast -o $(BINDIR)/mto-c mto.c

$(BINDIR)/mto-cc: mto.cc
	clang++ -Ofast -o $(BINDIR)/mto-cc mto.cc

$(BINDIR)/mto-objc: osx/objc-cli/main.m osx/objc-cli/MTODict.m
	clang -Ofast -o $(BINDIR)/mto-objc -framework Foundation osx/objc-cli/main.m osx/objc-cli/MTODict.m

$(BINDIR)/mto-swift: mto.swift
	xcrun --sdk `xcrun --show-sdk-path` swiftc -o $(BINDIR)/mto-swift mto.swift

$(BINDIR)/mto-go: mto.go
	go build -o $(BINDIR)/mto-go mto.go

$(BINDIR)/mto-mono: mto-mono.cs
	mcs -out:$(BINDIR)/mto-mono mto-mono.cs

$(BINDIR)/mto-ccl: mto-ccl.lisp
	@sed -e 's/unprocessed-command-line-arguments/command-line-argument-list/' mto-ccl.lisp > t1-mto-ccl.lisp
	@sed -e 's/;(mto-bin)/(mto-bin)/' t1-mto-ccl.lisp > t2-mto-ccl.lisp
	@sed -e 's/(main)/;(main)/' t2-mto-ccl.lisp > bin-mto-ccl.lisp
	ccl --no-init --load bin-mto-ccl.lisp
	@mv mto-ccl $(BINDIR)
	@rm *-mto-ccl.lisp

$(BINDIR)/mto-sbcl: mto-sbcl.lisp
	@sed -e 's/;(mto-bin)/(mto-bin)/' mto-sbcl.lisp > t1-mto-sbcl.lisp
	@sed -e 's/(main)/;(main)/' t1-mto-sbcl.lisp > bin-mto-sbcl.lisp
	sbcl --noinform --no-sysinit --no-userinit --load bin-mto-sbcl.lisp 1>/dev/null
	@mv mto-sbcl $(BINDIR)
	@rm *-mto-sbcl.lisp

# Section: TEST
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
	@sh $(TEST_PRG) python3 mto.py

test-rb:
	@echo "Ruby Test!"
	@sh $(TEST_PRG) ruby mto.rb

test-mrb:
	@echo "MRuby Test!"
	@sh $(TEST_PRG) mruby mto.rb

test-pl:
	@echo "Perl Test!"
	@sh $(TEST_PRG) perl mto.pl

test-lua:
	@echo "Lua Test!"
	@sh $(TEST_PRG) lua mto.lua

test-gosh:
	@echo "Gauche Test!"
	@sh $(TEST_PRG) gosh mto.scm

test-node:
	@echo "Node.js Test!"
	@sh $(TEST_PRG) node mto-node.js

test-php:
	@echo "PHP Test!"
	@sh $(TEST_PRG) php mto.php

test-mono: $(BINDIR)/mto-mono
	@echo "Mono Test!"
	@sh $(TEST_PRG) mono $<

test-go: $(BINDIR)/mto-go
	@echo "Go Test!"
	@sh $(TEST_PRG) $<

test-c: $(BINDIR)/mto-c
	@echo "C Test!"
	@sh $(TEST_PRG) $<

test-cc: $(BINDIR)/mto-cc
	@echo "CC Test!"
	@sh $(TEST_PRG) $<

test-ccl: $(BINDIR)/mto-ccl
	@echo "Clozure CL Test!"
	@sh $(TEST_PRG) $<

test-sbcl: $(BINDIR)/mto-sbcl
	@echo "SBCL Test!"
	@sh $(TEST_PRG) $<

test-objc: $(BINDIR)/mto-objc
	@echo "Objective-C Test!"
	@sh $(TEST_PRG) $<

test-swift: $(BINDIR)/mto-swift
	@echo "Swift Test!"
	@sh $(TEST_PRG) $<

# Section: benchmark
bench: bench64

bench32: bench/0032kib.txt
	ruby $(BENCH_PRG) $<

bench64: bench/0064kib.txt
	ruby $(BENCH_PRG) $<

bench128: bench/0128kib.txt
	ruby $(BENCH_PRG) $<

bench256: bench/0256kib.txt
	ruby $(BENCH_PRG) $<

bench512: bench/0512kib.txt
	ruby $(BENCH_PRG) $<

bench1024: bench/1024kib.txt
	ruby $(BENCH_PRG) $<

bench2048: bench/2048kib.txt
	ruby $(BENCH_PRG) $<

bench3072: bench/3072kib.txt
	ruby $(BENCH_PRG) $<

bench/0032kib.txt: bench/nippon.txt
	@cp $< $@

bench/0064kib.txt: bench/0032kib.txt
	@cat $< > $@
	@cat $< >> $@

bench/0128kib.txt: bench/0064kib.txt
	@cat $< > $@
	@cat $< >> $@

bench/0256kib.txt: bench/0128kib.txt
	@cat $< > $@
	@cat $< >> $@

bench/0512kib.txt: bench/0256kib.txt
	@cat $< > $@
	@cat $< >> $@

bench/1024kib.txt: bench/0512kib.txt
	@cat $< > $@
	@cat $< >> $@

bench/2048kib.txt: bench/1024kib.txt
	@cat $< > $@
	@cat $< >> $@

bench/3072kib.txt: bench/1024kib.txt bench/2048kib.txt
	@cat $^ > $@

# Section: CLEAN
clean:
	find bin -type file -perm 755 -exec rm -f {} ';'
	find . -type file -name '*.ok' -exec rm -f {} ';'
	find . -type file -name '*.out' -exec rm -f {} ';'

benchclean:
	find bench -type file -name '*kib.txt' -exec rm -f {} ';'
