/* bloody C and its incapacity to simply encode pairs */
#ifndef _UTILE_H
#define _UTILE_H

#define TYPE_NUMBER 3

#define S_VOID "void"
#define S_INT "i32"
#define S_FLOAT "float" 

#define S_BOOL_INT "icmp"
#define S_BOOL_FLOAT "fcmp"

enum type {T_VOID, T_INT, T_FLOAT};

enum loop_type{NONE, T_WHILE_DO, T_DO_WHILE};

typedef struct {
  int reg_id;
  enum type reg_type;
} registre;

typedef struct {
  int one;
  int two;
} label;

typedef void* sid;

typedef struct {
  sid symbol_name;
  int symbol_bloc;
} symbol_id;

typedef struct {
  symbol_id* symbol_name;
  enum type symbol_type; 
} elem;

typedef struct {
  sid name;
  enum type type;
} symbol;
#endif
