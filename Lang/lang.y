%{
#include <stdio.h>
#include <string.h>
#include "utile.h"
#include "symbol_table.h"
#include "conv_hex.h"


  void yyerror (char* s) {
    printf ("%s\n",s);
  }

  void yywrap () {

  }

  /* generation de numero de registre */

  registre new_reg(enum type reg_type) {
    registre reg;
    static int n = 0;
    reg.reg_id = n;
    reg.reg_type = reg_type;
    n++;
    return reg;
  }

  /* generation de numero de label */

  label new_label() {
    static int n = 0;
    label result;
    result.one = n++;
    result.two = n++;
    return result;
  }

 enum type op_type(enum type op1, enum type op2) {
   if( op1 == T_FLOAT || op2 == T_FLOAT) {
     return T_FLOAT;
  }
  else {
    return T_INT;
  }
 }

 void operation_type(enum type op1, enum type op2, char **type_string, char **operation_name, char **operation_type_name) {
   if(op_type(op1, op2) == T_FLOAT) {
    *(type_string) = S_FLOAT;
    *(operation_name) = operation_type_name[T_FLOAT];
  }
  else {
    *(type_string) = S_INT;
    *(operation_name) = operation_type_name[T_INT];
  }
}

  void printf_operation(int result, registre op1, registre op2, char ** operation_type_name, char * bool_operation) {
    char * type_string;
    char * operation_name;

    operation_type(op1.reg_type, op2.reg_type, &type_string, &operation_name, operation_type_name); 

    printf("\t %%r%i = %s %s %s %%r%d, %%r%d\n", result, operation_name, bool_operation, type_string, op1.reg_id, op2.reg_id);
  }


 char * string_of_type(enum type t) {
   char * type_string;
   switch (t) {
   case T_INT:
     type_string = S_INT;
     break;
   case T_FLOAT:
     type_string = S_FLOAT;
     break;
   default:
     type_string = "";
     break;
   }
   return type_string;
 }



%}

/* Le type union (plus ou moins mal définissable en C) permet de représenter l'union disjointe
de deux types.En maths, on peut poser A + B = ({1} x A) U ({2} x B).

Un élement de A + B est  alors de la forme (t,v) avec t = 1 ou 2. La valeur de t permet de savoir
si la valeur v est de type A  (lorsque t = 1) ou de type A (lorsque t = 2).

Le type union ci-dessous fait (presque) la même chose pour le type attribut, le "typage" d'un
attribut se faisant à l'utilisation par $<type>n. Exmple: $<sid>-3 indique que l'atrribut $-3
sera lue comme un char * (le type de sid). */


%union {
  int n;
  float f;
  char * sid;
  label lab;
  enum type t;
  registre reg;
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

%type <t> typename /*type*/
%type <reg> exp bool  /* attribut d’une expr = valeur entiere */
%type <lab> if else

%start prog



%%

prog : init block;

init: {create_table();};

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

fun_head : ID PO PF 
{
  char * type_string = string_of_type($<t>0);
  add_bloc(create_elem($1, $<t>0));
  printf("define %s @%s() {\nL0:\n",type_string, $1);}
| ID PO param_list PF;

fun_body : AO block AF {printf("}\n");};

type
: typename pointer //{$$ = strcat($1, "*");} TODO : marche pas
| typename /*{$$ = $1;}*/
;

typename
: INT {$$ = T_INT;}
| FLOAT {$$ = T_FLOAT;}
| VOID {$$ = T_VOID;}
;

pointer
: pointer STAR
| STAR
;

param_list: type ID vir param_list
| type ID;

vlist: ID vir vlist {
  char * type_string = string_of_type($<t>0);
  printf("\t %%%s = alloca %s\n", $1, type_string); 
  add_symbol(create_elem($1,$<t>0));};
| ID {
  char * type_string = string_of_type($<t>0);
  printf("\t %%%s = alloca %s\n", $1, type_string);
  add_symbol(create_elem($1,$<t>0));};

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

aff : ID EQ exp PV {
  char* string_type = string_of_type(find_type_from_name($1));
  printf("\t store %s %%r%i, %s* %%%s\n",string_type, $3.reg_id, string_type, $1);};

ret : RETURN PV
| RETURN exp PV {
  char* string_type = string_of_type(type_last_bloc());
  printf("\t ret %s %%r%i\n", string_type, $2.reg_id);};

cond :
if bool_cond inst %prec UNA {printf("L%i: ",$1.one);}
| if bool_cond inst else inst {printf("L%i: ",$1.two);};


 bool_cond : PO bool PF {printf("if i1 %%r%i, label %i, label \n",$2.reg_id,$<lab>0.one);};
	      // l'attribut du if est juste avant sur la pile.
	      // on doit préciser son type parce que YACC ne fait l'anlyse permettant de le savoir.
	      // Notez qu'on ne precise pas le type de $2

if : IF {$$ = new_label();};

else : ELSE {$$ = $<lab>-2; printf("goto L%i;\n",$$.two); printf("L%i: ",$$.one); };
    // l'attibut du if se trouve à trois niveau en dessus, sur la pile,
    // en effet, le else apparait sur la pile toujorus trois coups après le if (voir rêgle du cond).

// ce n'est pas la facon dont on souhaiterais coder les calculs booleens... (voir en dessous)

bool :
exp INF exp {
  $$ = new_reg(op_type($1.reg_type, $3.reg_type));
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$.reg_id, $1, $3, operation_type_name, "slt"); }
| exp SUP exp {
  $$ = new_reg(op_type($1.reg_type, $3.reg_type)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$.reg_id, $1, $3, operation_type_name, "sgt"); }
| exp EQUAL exp {
  $$ = new_reg(op_type($1.reg_type, $3.reg_type)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$.reg_id, $1, $3, operation_type_name, "eq"); }
| exp DIFF exp {
  $$ = new_reg(op_type($1.reg_type, $3.reg_type));
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$.reg_id, $1, $3, operation_type_name, "ne"); }
| bool AND bool {
  $$ = new_reg(op_type($1.reg_type, $3.reg_type)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$.reg_id, $1, $3, operation_type_name, "ne"); }
| bool OR bool {$$ = new_reg(op_type($1.reg_type, $3.reg_type)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$.reg_id, $1, $3, operation_type_name, "ne"); }
| NOT bool {$$ = new_reg($2.reg_type); printf("\t %%r%i = ! R%i;\n", $$.reg_id, $2.reg_id); }
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
: MOINS exp %prec UNA {$$ = new_reg($2.reg_type); printf("R%i = - R%i;\n", $$.reg_id, $2.reg_id); }
| PLUS exp %prec UNA {$$ = new_reg($2.reg_type); printf("R%i = - R%i;\n", $$.reg_id, $2.reg_id); }
| exp PLUS exp {
  $$ = new_reg(op_type($1.reg_type, $3.reg_type)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "add", "fadd"};
  printf_operation($$.reg_id, $1, $3, operation_type_name, ""); }

| exp MOINS exp {
  $$ = new_reg(op_type($1.reg_type, $3.reg_type)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "sub", "fsub"};
  printf_operation($$.reg_id, $1, $3, operation_type_name, ""); }

| exp STAR exp {
  $$ = new_reg(op_type($1.reg_type, $3.reg_type)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "mul", "fmul"};
  printf_operation($$.reg_id, $1, $3, operation_type_name, ""); }

| exp DIV exp {
  $$ = new_reg(op_type($1.reg_type, $3.reg_type)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "div", "fdiv"};
  printf_operation($$.reg_id, $1, $3, operation_type_name, ""); }

| PO exp PF {$$=$2;}
| ID {$$ = new_reg(find_type_from_name($1));
  char * type_string = string_of_type(find_type_from_name($1));
  printf("\t %%r%i = load %s, %s* %%%s\n", $$.reg_id, type_string, type_string, $1); }
| CONSTANTI {$$ = new_reg(T_INT); 
  printf("\t %%r%i = add i32 %i, 0\n", $$.reg_id, $1); }
| CONSTANTF {$$ = new_reg(T_FLOAT);
  printf("\t %%r%i = fadd float %s, %s \n", $$.reg_id, float_to_hex($1), float_to_hex(0.0)); }
| fun_app {$$ = new_reg(T_INT); printf("R%i = TODO\n", $$.reg_id); }
;



%%
int main () {

return yyparse ();
}
