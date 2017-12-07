%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utile.h"
#include "symbol_table.h"
#include "conv_hex.h"

  static int label_n = 0;
  static enum loop_type lt = NONE;

  int yyerror (char* s) {
    fprintf(stderr,"error: %s\n",s);
    return EXIT_FAILURE;
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

  label new_simple_label() {
    label result;
    result.one = label_n;
    result.two = label_n++;
    return result;    
  }
  label new_double_label() {
    label result;
    result.one = label_n++;
    result.two = label_n++;
    return result;
  }
  
  void convert_int_to_float(int reg_id_dest, int reg_id_src) {
    printf("\t %%r%i = sitofp %s %%r%i to %s\n", reg_id_dest, S_INT, reg_id_src, S_FLOAT);
  }
  void convert_float_to_int(int reg_id_dest, int reg_id_src) {
    printf("\t %%r%i = fptosi %s %%r%i to %s\n", reg_id_dest, S_FLOAT, reg_id_src, S_INT);
  }

  void copy_registre(registre *dest, registre src) {
    dest->reg_id = src.reg_id;
    dest->reg_type = src.reg_type;
  }

  void convert_to_function_type(enum type f_type, registre *exp) {
    if(f_type != exp->reg_type) {
      registre tmp;
      if(exp->reg_type == T_INT) {
	tmp = new_reg(T_FLOAT);
	convert_int_to_float(tmp.reg_id, exp->reg_id);
      }
      else {
	tmp = new_reg(T_INT);
	convert_float_to_int(tmp.reg_id, exp->reg_id);
      }
      copy_registre(exp, tmp);
    }
  }

 enum type op_type(registre *op1, registre *op2) {
   if( op1->reg_type == T_FLOAT || op2->reg_type == T_FLOAT) {
     if (op1->reg_type == T_INT) {
       registre tmp = new_reg(T_FLOAT);
       convert_int_to_float(tmp.reg_id, op1->reg_id);
       copy_registre(op1, tmp);
       
     }
     else if (op2->reg_type == T_INT) {
       registre tmp = new_reg(T_FLOAT);
       convert_int_to_float(tmp.reg_id, op2->reg_id);
       copy_registre(op2, tmp);
     }
     return T_FLOAT;
  }
  else {
    return T_INT;
  }
 }

 void operation_type(registre result, registre op1, registre op2, char **type_string, char **operation_name, char **operation_type_name) {
   if(result.reg_type == T_FLOAT) {
    *(type_string) = S_FLOAT;
    *(operation_name) = operation_type_name[T_FLOAT];
  }
  else {
    *(type_string) = S_INT;
    *(operation_name) = operation_type_name[T_INT];
  }
}

  void printf_operation(registre result, registre op1, registre op2, char ** operation_type_name, char * bool_operation) {
    char * type_string;
    char * operation_name;

    operation_type(result, op1, op2, &type_string, &operation_name, operation_type_name); 
    
    printf("\t %%r%i = %s %s%s %%r%d, %%r%d\n", result.reg_id, operation_name, bool_operation, type_string, op1.reg_id, op2.reg_id);
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
%type <lab> else while do bool_cond

%start prog



%%

prog : init block  {destroy_table();}; 

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
  add_symbol(create_elem($1, $<t>0));
  printf("define %s @%s() {\n",type_string, $1);
  printf("L%i:\n", new_simple_label().one);}
| ID PO param_list PF;

fun_body : ao block af {printf("}\n");};

ao: AO {add_bloc();}

af: AF {remove_bloc();}

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
  elem x = create_elem($1,$<t>0);
  if(search_symbol_in_bloc(x)) {
    yyerror("variable already created !");
  }
  char * type_string = string_of_type(x.symbol_type);
  printf("\t %%", x.symbol_name);
  display_symbol_id(x.symbol_name);
  printf(" = alloca %s\n", type_string);
  add_symbol(x);};
| ID {
  elem x = create_elem($1,$<t>0);
  if(search_symbol_in_bloc(x)) {
    printf("variable already created !");
  }  
  char * type_string = string_of_type(x.symbol_type);
  printf("\t %%", x.symbol_name);
  display_symbol_id(x.symbol_name);
  printf(" = alloca %s\n", type_string);
  add_symbol(x);};

vir : VIR;

// intructions

inst_list: inst inst_list
|
;

inst:
exp PV
| ao block af
| cond
| loop
| aff
| ret
| PV;

loop : while bool_cond do ao block af { lt = NONE; decrement_depth_control(); printf("\t br label %%L%i\n", $1.one);
    printf("L%i: \n", $2.two);}
| do ao block af while bool_cond PV {lt = NONE;}
;

 while : WHILE {
   if(lt == NONE) { 
    $$ = new_simple_label();
    printf("\t br label %%L%i \n", $$.one);
    printf("L%i: \n", $$ .one);
    lt = T_WHILE_DO; 
   }
   else if(lt == T_DO_WHILE) {
     decrement_depth_control();
   }
};

do : DO {
  if(lt == NONE) {
    $$ = new_simple_label();
    printf("\t br label %%L%i \n", $$.one);
    printf("L%i: \n", $$.one);
    lt = T_DO_WHILE;
  }
  add_symbol(create_elem("do", T_VOID));
  increment_depth_control();
     };

       
fun_app : ID PO args PF;

args : arglist
| ;

arglist : ID VIR arglist
| ID;

aff : ID EQ exp PV {
  elem symbol = find_elem_from_name($1);
  if( symbol.symbol_type == T_VOID) {
    printf("ID in aff\n");
    yyerror("symbol not found !");
  }
  char* string_type = string_of_type(symbol.symbol_type);
  printf("\t store %s %%r%i, %s* %%",string_type, $3.reg_id, string_type);
  display_symbol_id(symbol.symbol_name);
  printf("\n");};

ret : RETURN PV
| RETURN exp PV {
  enum type return_type = type_last_bloc();
  convert_to_function_type(return_type, &$2);
  char* string_type = string_of_type(return_type);
  printf("\t ret %s %%r%i\n", string_type, $2.reg_id);};

cond :
if bool_cond inst %prec UNA {decrement_depth_control(); printf("\t br label %%L%i\n", $2.two);printf("L%i:\n",$2.two);}
| if bool_cond inst else inst {decrement_depth_control(); printf("\t br label %%L%i\n", $4.one);printf("L%i:\n",$4.one);};


bool_cond : PO bool PF {
  int label_true;
  int label_false;
  int label_displayed;
  if(lt == NONE) {
    increment_depth_control();
  }
  if(lt != T_DO_WHILE) {
    $$ = new_double_label(); 
    label_true = $$.one;
    label_false = $$.two;
    label_displayed = label_true;
  }
  else {
    $$ = new_simple_label();
    label_true = $<lab>0.one;
    label_false = $$.one;
    label_displayed = label_false;
  }
  printf("\t br i1 %%r%i, label %%L%i, label %%L%i\n", $2.reg_id,label_true, label_false);
  printf("L%i:\n", label_displayed);
};
	      // l'attribut du if est juste avant sur la pile.
	      // on doit préciser son type parce que YACC ne fait l'anlyse permettant de le savoir.
	      // Notez qu'on ne precise pas le type de $2

if : IF {
add_symbol(create_elem("if", T_VOID)); };

 else : ELSE {
   add_symbol(create_elem("else", T_VOID));
   $$ = new_simple_label()/*$<lab>-2*/; printf("\t br label %%L%i\n",$$.one); printf("L%i:\n",($<lab>-1).two); };
    // l'attibut du if se trouve à trois niveau en dessus, sur la pile,
    // en effet, le else apparait sur la pile toujorus trois coups après le if (voir rêgle du cond).

// ce n'est pas la facon dont on souhaiterais coder les calculs booleens... (voir en dessous)

bool :
exp INF exp {
  $$ = new_reg(op_type(&$1, &$3));
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$, $1, $3, operation_type_name, "slt "); }
| exp SUP exp {
  $$ = new_reg(op_type(&$1, &$3)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$, $1, $3, operation_type_name, "sgt "); }
| exp EQUAL exp {
  $$ = new_reg(op_type(&$1, &$3)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$, $1, $3, operation_type_name, "eq "); }
| exp DIFF exp {
  $$ = new_reg(op_type(&$1, &$3));
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$, $1, $3, operation_type_name, "ne "); }
| bool AND bool {
  $$ = new_reg(op_type(&$1, &$3)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$, $1, $3, operation_type_name, "ne"); }
| bool OR bool {$$ = new_reg(op_type(&$1, &$3)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "icmp", "fcmp"};
  printf_operation($$, $1, $3, operation_type_name, "ne"); }
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
| exp PLUS exp {
  $$ = new_reg(op_type(&$1, &$3)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "add", "fadd"};
  printf_operation($$, $1, $3, operation_type_name, ""); }

| exp MOINS exp {
  $$ = new_reg(op_type(&$1, &$3)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "sub", "fsub"};
  printf_operation($$, $1, $3, operation_type_name, ""); }

| exp STAR exp {
  $$ = new_reg(op_type(&$1, &$3)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "mul", "fmul"};
  printf_operation($$, $1, $3, operation_type_name, ""); }

| exp DIV exp {
  $$ = new_reg(op_type(&$1, &$3)); 
  char * operation_type_name[TYPE_NUMBER] = {"", "div", "fdiv"};
  printf_operation($$, $1, $3, operation_type_name, ""); }

| PO exp PF {$$=$2;}
| ID {
  elem symbol = find_elem_from_name($1);
  if(symbol.symbol_type == T_VOID) {
    printf("%s\n", $1);
    printf("ID in exp\n");
    yyerror("symbol not found !\n");
  }
  $$ = new_reg(symbol.symbol_type);
  char * type_string = string_of_type(symbol.symbol_type);
  printf("\t %%r%i = load %s, %s* %%", $$.reg_id, type_string, type_string); 
  display_symbol_id(symbol.symbol_name);
  printf("\n");}
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
