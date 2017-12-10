EXECUTABLE_PATH = ../bin/compiler
ERREUR_FILE = erreur_message.txt 
LLVM_FILE = $(patsubst %.c,%.ll,$(wildcard *.c))

.PHONY: all compile_test

%.ll: %.c
	./$(EXECUTABLE_PATH)< $< 1> $@ 2> $(ERREUR_FILE)


all : compile_test

compile_test: $(LLVM_FILE)
