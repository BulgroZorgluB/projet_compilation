

all		:	

conv_hex.o 	:       conv_hex.c
			gcc -std=c99 -c conv_hex.c


y.tab.o	        :       y.tab.c

lex.yy.o	: 	lex.yy.c

linked_list.o	:	linked_list.c

symbol_table.o	:	symbol_table.c

list_of.o	:	list_of.c

prog		:	lex.yy.o y.tab.o symbol_table.o linked_list.o list_of.o
					gcc  lex.yy.o y.tab.o symbol_table.o linked_list.o list_of.o conv_hex.o -o $(EXECUTABLE_PATH)
