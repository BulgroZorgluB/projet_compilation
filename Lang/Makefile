CFLAGS += -g

all		:	y.tab.h lex.yy.c y.tab.c prog

y.tab.h         :       lang.y
			bison -y -d -v lang.y
lex.yy.c	:	lang.l 
			flex lang.l 
y.tab.c		:	lang.y
			bison -d -v lang.y
y.tab.o	        :       y.tab.c
lex.yy.o	: 	lex.yy.c
Table_des_chaines.o	:	Table_des_chaines.c 
Table_des_symboles.o	:	Table_des_symboles.c
prog		:	lex.yy.o y.tab.o Table_des_symboles.o Table_des_chaines.o
			gcc  lex.yy.o y.tab.o Table_des_symboles.o Table_des_chaines.o -o prog
clean		:	
			rm -f 	lex.yy.c *.o y.tab.h y.tab.c prog *~ y.output
