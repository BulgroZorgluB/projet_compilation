CFLAGS += -g
EXECUTABLE_PATH= ../bin/

all		:	y.tab.h lex.yy.c y.tab.c prog

y.tab.h         :       lang.y
			bison -y -d -v lang.y
lex.yy.c	:	lang.l 
			flex lang.l 
y.tab.c		:	lang.y
			bison -d -v lang.y

prog		:	lex.yy.o y.tab.o symbol_table.o linked_list.o list_of.o conv_hex.o
				gcc  lex.yy.o y.tab.o symbol_table.o linked_list.o list_of.o conv_hex.o -o $(EXECUTABLE_PATH)compiler

clean		:	
			rm -f 	lex.yy.c *.o y.tab.h y.tab.c $(EXECUTABLE_PATH)/compiler *~ y.output



