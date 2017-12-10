CFLAGS += -g
EXECUTABLE_PATH= ../bin/compiler

all		:	conv_hex.o y.tab.h lex.yy.c y.tab.c prog

conv_hex.o 	:       
			gcc -std=c99 -c conv_hex.c

y.tab.h         :       lang.y
			bison -y -d -v lang.y
lex.yy.c	:	lang.l 
			flex lang.l 
y.tab.c		:	lang.y
			bison -d -v lang.y
y.tab.o	        :       y.tab.c

lex.yy.o	: 	lex.yy.c

linked_list.o	:	linked_list.c

symbol_table.o	:	symbol_table.c

list_of.o	:	list_of.c

prog		:	lex.yy.o y.tab.o symbol_table.o linked_list.o list_of.o
					gcc  lex.yy.o y.tab.o symbol_table.o linked_list.o list_of.o conv_hex.o -o $(EXECUTABLE_PATH)
clean		:	
			rm -f 	lex.yy.c *.o y.tab.h y.tab.c $(EXECUTABLE_PATH) *~ y.output
