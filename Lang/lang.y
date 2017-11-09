%{
#include <stdio.h>
#include "utile.h"
#include "Table_des_symboles.h"

  void yyerror (char* s) {
    printf ("%s\n",s);
  }

  void yywrap () {

  }


  /* generation de numero de registre */

  int new_reg() {
    static int n = 0;
    return n++;
  }

  /* generation de numero de label */

  label new_label() {
    static int n = 0;
    label result;
    result.one = n++;
    result.two = n++;
    return result;
  }



%}

/* Le type union (plus ou moins mal définissable en C) permet de représenter l'union disjointe
de deux types.En maths, on peut poser A + B = ({1} x A) U ({2} x B).

Un élement de A + B est  alors de la forme (t,v) avec t = 1 ou 2. La valeur de t permet de savoir
si la valeur v est de type A  (lorsque t = 1) ou de type A (lorsque t = 2).

Le type union ci-dessous fait (presque) la même chose pour le type attribut, le "typage" d'un
attribut se faisant à l'utilisation par $<type>n. Example: $<sid>-3 indique que l'atrribut $-3
sera lue comme un char * (le type de sid). */


%union {
  int n;
  float f;
  int reg;
  char * sid;
  label lab;
}

%token <n> CONSTANTI /* attribut d’une constante entière = int */
%token <f> CONSTANTF /* attribut d’une constante flottante = float */

%token <sid> ID  /* attribut d’un registre = sid */

%token IF ELSE


%token INT FLOAT VOID

%token VIR PV AO AF PO PF
%token UNTIL DO WHILE RETURN

%token PLUS MOINS STAR DIV  EQ
%token INF EQUAL SUP DIFF
%token AND OR NOT

%left PLUS MOINS
%left STAR DIV    /* * et / plus prioritaires que + et - */

%nonassoc NOT
%left OR
%left AND
%nonassoc UNA    /* pseudo token pour assurer une priorite locale */
%nonassoc ELSE

%type <reg> exp bool  /* attribut d’une expr = valeur entiere */
%type <lab> if else

%start prog



%%

prog : block;

block:
decl_list inst_list
;

// declarations

decl_list : decl decl_list
| ;

decl: var_decl PV
| fun_decl;

var_decl : type vlist;

fun_decl : type fun;

fun : fun_head fun_body;

fun_head : ID PO PF {printf("define i32 @%s() {\nL0:\n",$1);}
| ID PO param_list PF;

fun_body : AO block AF {printf("}\n");};

type
: typename pointer
| typename
;

typename
: INT
| FLOAT
| VOID
;

pointer
: pointer STAR
| STAR
;

param_list: type ID vir param_list
| type ID;

vlist: ID vir vlist {printf("\t %%%s = alloca i32\n", $1);}
| ID {printf("\t %%%s = alloca i32\n", $1);};

vir : VIR;

// intructions

inst_list: inst inst_list
|
;

inst:
exp PV
| AO block AF
| cond
| loop
| aff
| ret
| PV;

loop : WHILE PO exp PF DO AO block AF
| DO AO block AF WHILE PO exp PF PV
;

fun_app : ID PO args PF;

args : arglist
| ;

arglist : ID VIR arglist
| ID;

aff : ID EQ exp PV {printf("\t store i32 %%r%i, i32* %%%s\n", $3,$1);};

ret : RETURN PV
| RETURN exp PV {printf("\t ret i32 %%r%i\n", $2);};

cond :
if bool_cond inst %prec UNA {printf("L%i: ",$1.one);}
| if bool_cond inst else inst {printf("L%i: ",$1.two);};


 bool_cond : PO bool PF {printf("if !R%i goto L%i;\n",$2,$<lab>0.one);};
	      // l'attribut du if est juste avant sur la pile.
	      // on doit préciser son type parce que YACC ne fait l'anlyse permettant de le savoir.
	      // Notez qu'on ne precise pas le type de $2

if : IF {$$ = new_label();};

else : ELSE {$$ = $<lab>-2; printf("goto L%i;\n",$$.two); printf("L%i: ",$$.one); };
    // l'attibut du if se trouve à trois niveau en dessus, sur la pile,
    // en effet, le else apparait sur la pile toujorus trois coups après le if (voir rêgle du cond).

// ce n'est pas la facon dont on souhaiterais coder les calculs booleens... (voir en dessous)

bool :
exp INF exp {$$ = new_reg(); printf("R%i = (R%i < R%i);\n", $$,$1,$3); }
| exp SUP exp {$$ = new_reg(); printf("R%i = (R%i > R%i);\n", $$,$1,$3); }
| exp EQUAL exp {$$ = new_reg(); printf("R%i = (R%i == R%i);\n", $$,$1,$3); }
| exp DIFF exp {$$ = new_reg(); printf("R%i = (R%i != R%i);\n", $$,$1,$3); }
| bool AND bool {$$ = new_reg(); printf("R%i = R%i && R%i;\n", $$,$1,$3); }
| bool OR bool {$$ = new_reg(); printf("R%i = R%i && R%i;\n", $$,$1,$3); }
| NOT bool {$$ = new_reg(); printf("R%i = ! R%i;\n", $$,$2); }
| PO bool PF{$$ = $2;};

// Comment faire à la place une évaluation "paresseuse" des booléens ?
// Idée: le programme produit pour coder un booléen est un morceau de code c associé à deux labels,
// LF et LT. Le code c "branche" à LF si le booleen est faux et il branche à LT s'il est vrai.

// Comment alors combiner les codes des booléens et leurs labels pour produire un code paresseux ?
// Idée (sur l'exemple de la conjonction b1 && b2) :
// - avec b1 qui produit un code c1 et une paire de labels (LF1,LT1) ... dans son attribut
// - avec b2 qui produit un code c2 et une paire de labels (LF2,LT2) ... dans son attribut
// on peut produire le code c pour b1 && b2 suivant:
// c1
// LT1:
// c2
// LF1: goto LF2
// et la paire de label (LF2,LT2)

// Pour faire celà, on peut "retarder" la lecture du OR ou du AND par
// or : OR;
// and : AND;

// Comment traiter le NOT ?
// Comment traduire alors le if then ou le if then else.. ?

// Historiquement, ce codage est due à Alonzo Church avec son lambda calcul...

exp
: MOINS exp %prec UNA {$$ = new_reg(); printf("R%i = - R%i;\n", $$,$2); }
| exp PLUS exp {$$ = new_reg(); printf("\t %%r%i = add i32 %%r%i, %%r%i\n", $$,$1,$3); }
| exp MOINS exp {$$ = new_reg(); printf("R%i = R%i - R%i;\n", $$,$1,$3); }
| exp STAR exp {$$ = new_reg(); printf("\t %%r%i = mul i32 %%r%i, %%r%i\n", $$,$1,$3); }
| exp DIV exp {$$ = new_reg(); printf("\t %%r%i = sdiv i32 %%r%i, %%r%i\n", $$,$1,$3); }
| PO exp PF {$$=$2;}
| ID {$$ = new_reg(); printf("R%i = %s;\n", $$,$1); }
| CONSTANTI {$$ = new_reg(); printf("\t %%r%i = add i32 %i, 0\n", $$,$1); }
| CONSTANTF {$$ = new_reg(); printf("R%i = %f;\n", $$,$1); }
| fun_app {$$ = new_reg(); printf("R%i = TODO\n", $$); }
;



%%
int main () {
return yyparse ();
}
