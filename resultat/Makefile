EXECUTABLE_PATH = ../bin/compiler

LLVM_FILE = $(patsubst %.c,%.ll,$(wildcard *.c))

.PHONY: all compile_test

%.ll: %.c
	./$(EXECUTABLE_PATH)< $< 1> $@ 2> $(patsubst %.ll,%.txt, $@)


all : compile_test

compile_test: $(LLVM_FILE)

clean:
	rm $(LLVM_FILE) $(patsubst %.ll,%.txt, $(LLVM_FILE))
