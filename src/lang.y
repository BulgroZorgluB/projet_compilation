%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utile.h"
#include "symbol_table.h"
#include "conv_hex.h" 
#include "list_of.h"

  static int label_n = 0;
  
  static enum loop_type *lt;
  static int loop_depth= -1;
  
  static list_of *arg_list;
  static list_of *function_list;

  void init_loop_depth() {
    lt = malloc(sizeof(enum loop_type));
  }
  
  void add_loop_depth() {
    loop_depth++;
    lt = realloc(lt, sizeof(enum loop_type) * (loop_depth + 1));
  }

  void remove_loop_depth() {
    loop_depth--;
  }

  void free_loop_depth() {
    free(lt);
  }
  
  void yyerror (char* s) {
    fprintf(stderr,"error: %s\n",s);
    exit(1);
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
     type_string = S_VOID;
     break;
   }
   return type_string;
 }

 void add_new_variables(node n) {
   int size = n.size;
   elem variable_values[size];
   char *string_type[size];
   int i = 0;
   while ( i < size) {
     symbol s = (n.arguments[i]).s;
     variable_values[i] = create_elem(s.name, s.type);
     add_symbol(variable_values[i]);
     printf("\t %%");
     display_symbol_id(variable_values[i].symbol_name);
     string_type[i] = string_of_type(s.type);
     printf(" = alloca %s\n", string_type[i]);
     ++i;
   }
   i = 0;
   while (i < size) {
     symbol s = (n.arguments[i]).s;
     printf("\t store %s %%%s, %s* %%", string_type[i], s.name, string_type[i], variable_values[i].symbol_name->symbol_name);
     display_symbol_id(variable_values[i].symbol_name);
     printf("\n");
     ++i;
   }
 }

 void printf_symbol(symbol s) {
   printf("%s %%%s", string_of_type(s.type), s.name);
 }

 void printf_registre(registre r) {
   printf("%s %%r%i", string_of_type(r.reg_type), r.reg_id);
 }

 void printf_call_parameters(list_of *l) {
   int size = l->size;
   int i = 0;
   if( size != 0) {
     printf_registre((l->nodes[i]).r);
     ++i;
     while ( i < size) {
       printf(", ");
       printf_registre((l->nodes[i]).r);
       ++i;
       }
   }
 }

 void printf_parameters(node n) {
   int size = n.size;
   int i = 0;
   printf_symbol((n.arguments[i]).s);
   ++i;
   while ( i < size) {
     printf(", ");
     printf_symbol((n.arguments[i]).s);
     ++i;
   }
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

%token <sid> ID /* attribut d’un registre = sid */

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

%type <sid> fun_name
%type <t> typename /*type*/
%type <reg> exp bool fun_app  /* attribut d’une expr = valeur entiere */
%type <lab> else while do bool_cond and or

%start prog



%%

prog : init block {destroy_table(); free_loop_depth();}; 

init: {create_table(); init_loop_depth(); arg_list = init_list(REGISTER); function_list = init_list(SYMBOL);};

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

fun_head : fun_name PO PF 
{
  char * type_string = string_of_type($<t>0);
  add_symbol(create_elem($1, $<t>0));
  printf("define %s @%s() {\n",type_string, $1);
  printf("L%i:\n", new_simple_label().one);
}
| fun_name PO param_list PF {
  char * type_string = string_of_type($<t>0);
  node n = function_list->nodes[(function_list->size) - 1];
  add_symbol(create_elem($1, $<t>0));
  printf("define %s @%s(", type_string, $1);
  printf_parameters(n);
  printf("){\n");
  printf("L%i:\n", new_simple_label().one);
};

fun_name : ID {$$ = $1; function_list = add_symbol_node(function_list, $<t>0, $$);};

fun_body : ao fun_start block af {printf("}\n");};

ao: AO {
  if(get_depth_bloc() != 0) {
    increment_depth_control();
  }
  add_bloc();
}

fun_start: { 
  node n = function_list->nodes[(function_list->size) - 1];
  add_new_variables(n);
};

af: AF {
  if(get_depth_control() != 0) {
    decrement_depth_control();
  }
  if(get_depth_bloc() == 1 && type_last_bloc() == T_VOID)  {
    printf("\t ret void\n");
  }
  remove_bloc();
};

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

param_list: type ID vir param_list {add_argument_node(function_list, $<t>1, $2);}
| type ID {add_argument_node(function_list, $<t>1, $2);};

vlist: ID vir vlist {
  elem x = create_elem($1,$<t>0);
  if(search_symbol_in_bloc(x)) {
    yyerror("variable already created !");
  }
  char * type_string = string_of_type(x.symbol_type);
  printf("\t %%");
  display_symbol_id(x.symbol_name);
  printf(" = alloca %s\n", type_string);
  add_symbol(x);};
| ID {
  elem x = create_elem($1,$<t>0);
  if(search_symbol_in_bloc(x)) {
    printf("variable already created !");
  }  
  char * type_string = string_of_type(x.symbol_type);
  printf("\t %%");
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
| init_lt cond
| init_lt loop
| aff
| ret
| PV;

init_lt: {add_loop_depth(); lt[loop_depth] = NONE;};

loop : while bool_cond do ao block af { remove_loop_depth(); printf("\t br label %%L%i\n", $1.one);
    printf("L%i: \n", $2.two);}
| do ao block af while bool_cond PV {remove_loop_depth();}
;

 while : WHILE {
   if(lt[loop_depth] == NONE) { 
    $$ = new_simple_label();
    printf("\t br label %%L%i \n", $$.one);
    printf("L%i: \n", $$ .one);
    lt[loop_depth] = T_WHILE_DO; 
   }
};

do : DO {
  if(lt[loop_depth] == NONE) {
    $$ = new_simple_label();
    printf("\t br label %%L%i \n", $$.one);
    printf("L%i: \n", $$.one);
    lt[loop_depth] = T_DO_WHILE;
  }
  add_symbol(create_elem("do", T_VOID));
     };

       
fun_app : ID PO args PF 
{
  int i = function_index(function_list, $1);
  if( i == -1) {
    printf("ID in fun_app\n");
    yyerror("symbol not found !");    
  }
  node function = function_list->nodes[i];
  if(arg_list->size != function.size ) {
    printf("size in fun_app\n");
    yyerror("not the same size");
  }
  int j = 0;
  while (j < function.size) {
    symbol s = (function.arguments[j]).s;
    node arg = arg_list->nodes[j];
    char * type_string = string_of_type((arg.r).reg_type);
    printf("\t %%r%i = load %s, %s* %%", (arg.r).reg_id, type_string, type_string); 
    display_symbol_id(arg.name);
    printf("\n");
    if((arg.r).reg_type != s.type) {
      registre tmp;
      if((arg.r).reg_type == T_INT) {
	arg_list->nodes[j].r = new_reg(T_FLOAT);
	tmp = arg_list->nodes[j].r;
	convert_int_to_float(tmp.reg_id, (arg.r).reg_id);
      }
      else {
	arg_list->nodes[j].r = new_reg(T_INT);
	tmp = arg_list->nodes[j].r;
	convert_float_to_int(tmp.reg_id, (arg.r).reg_id);
      }
    }
    ++j;
  }
  $$ = new_reg(function.s.type);
  char * string_type = string_of_type(function.s.type);
  printf("\t %%r%i = call %s @%s(", $$.reg_id, string_type, function.s.name);
  printf_call_parameters(arg_list);
  printf(")\n");

  //init for a new call.
  arg_list->size = 0;
};

args : arglist
| ;

arglist : ID VIR arglist {
  elem symbol = find_elem_from_name($1);
  if (symbol.symbol_name == NULL) {
    printf("ID in arg_list\n");
    yyerror("symbol not found !");    
  }
  arg_list = add_registre_node(arg_list, new_reg(symbol.symbol_type), symbol.symbol_name);
}
| ID 
{
  elem symbol = find_elem_from_name($1);
  if (symbol.symbol_name == NULL) {
    printf("ID in arg_list\n");
    yyerror("symbol not found !");    
  }
  arg_list = add_registre_node(arg_list, new_reg(symbol.symbol_type), symbol.symbol_name);
};

aff : ID EQ exp PV {
  elem symbol = find_elem_from_name($1);
  if( symbol.symbol_type == T_VOID) {
    printf("ID in aff %s\n", $1);
    yyerror("symbol not found !");
  }
  if ($3.reg_type == T_VOID) {
    yyerror("trying to aff void value");
  }
  registre tmp;
  if ($3.reg_type != symbol.symbol_type) {

    if( $3.reg_type == T_INT) {
      tmp = new_reg(T_FLOAT);
      convert_int_to_float(tmp.reg_id, $3.reg_id);
    }
    else {
      tmp = new_reg(T_INT);
      convert_float_to_int(tmp.reg_id, $3.reg_id);
    }
  }
  else {
    tmp = $3;
  }
  char* string_type = string_of_type(symbol.symbol_type);
  printf("\t store %s %%r%i, %s* %%",string_type, tmp.reg_id, string_type);
  display_symbol_id(symbol.symbol_name);
  printf("\n");};

ret : RETURN PV
| RETURN exp PV {
  enum type return_type = type_last_bloc();
  if(return_type == VOID) {
    yyerror("void type returning something");
  }
  convert_to_function_type(return_type, &$2);
  char* string_type = string_of_type(return_type);
  printf("\t ret %s %%r%i\n", string_type, $2.reg_id);};

cond :
if bool_cond inst %prec UNA { printf("\t br label %%L%i\n", $2.two);printf("L%i:\n",$2.two);}
| if bool_cond inst else inst { printf("\t br label %%L%i\n", $4.one);printf("L%i:\n",$4.one);};


bool_cond : PO bool PF {
  int label_true;
  int label_false;
  int label_displayed;
  if(lt[loop_depth] != T_DO_WHILE) {
    $$ = new_double_label(); 
    label_true = $$.one;
    label_false = $$.two;
    label_displayed = label_true;
  }
  else {
    $$ = new_simple_label();
    label_true = $<lab>-4.one;
    label_false = $$.one;
    label_displayed = label_false;
  }
  printf("\t br i1 %%r%i, label %%L%i, label %%L%i\n", $2.reg_id, label_true, label_false);
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
| bool and bool UNA {$$ = $3;}

| bool or bool UNA {$$ = $3;}

| NOT bool {$$ = new_reg($2.reg_type); printf("\t %%r%i = ! R%i;\n", $$.reg_id, $2.reg_id); }
| PO bool PF{$$ = $2;};

and: AND {
  int label_true;
  int label_false;
  int label_displayed;
  int label_out;
  $$ = new_double_label(); 
  label_true = $$.one;
  label_false = $$.two;
  if(lt[loop_depth] != T_DO_WHILE) {
    label_displayed = label_true;
    label_out = label_displayed + 3; // label_false du bool suivant
  }
  else {
    label_displayed = label_true;
    label_out = label_displayed + 2; // label true du bool suivant
  }
  printf("\t br i1 %%r%i, label %%L%i, label %%L%i\n", $<reg>0.reg_id,label_true, label_false);
  printf("L%i:\n", label_false);
  printf("\t br label %%L%i\n", label_out);
  printf("L%i:\n", label_displayed);
};

or: OR {
  int label_true;
  int label_false;
  int label_displayed;
  int label_out;
  $$ = new_double_label(); 
  if(lt[loop_depth] != T_DO_WHILE) {
    label_true = $$.one;
    label_false = $$.two;
    label_displayed = label_false;
    label_out = label_displayed + 1; //label_true du bool suivant
  }
  else {
    label_false = $$.one;
    label_true = $$.two;
    label_displayed = label_false;
    label_out = label_displayed +1 - 2; //label_true du bool précédent
  }
  printf("\t br i1 %%r%i, label %%L%i, label %%L%i\n", $<reg>0.reg_id,label_true, label_false);
  printf("L%i:\n", label_true);
  printf("\t br label %%L%i\n", label_out);
  printf("L%i:\n", label_displayed);
};

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

exp:
MOINS exp %prec UNA {
  $$ = new_reg($2.reg_type); 
  if ( $2.reg_type == T_INT ) {
    printf("\t %%r%i = sub %s %d, %%r%i \n", $$.reg_id, S_INT, 0, $2.reg_id);
  }
  else {
    printf("\t %%r%i = fsub %s %s, %%r%i \n", $$.reg_id, S_FLOAT, float_to_hex(0.0), $2.reg_id); 
    }
}
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
  char * operation_type_name[TYPE_NUMBER] = {"", "sdiv", "fdiv"};
  printf_operation($$, $1, $3, operation_type_name, ""); }

| PO exp PF {$$=$2;}
| ID {
  elem symbol = find_elem_from_name($1);
  if(symbol.symbol_type == T_VOID) {
    printf("ID in exp %s\n", $1);
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
| fun_app {$$ = $1; }
;



%%
int main () {

return yyparse ();
}
