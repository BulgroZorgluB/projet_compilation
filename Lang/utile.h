/* bloody C and its incapacity to simply encode pairs */
#ifndef _UTILE_H
#define _UTILE_H

#define TYPE_NUMBER 3

#define S_INT "i32"
#define S_FLOAT "float" 

#define S_BOOL_INT "icmp"
#define S_BOOL_FLOAT "fcmp"

typedef struct {
  int one;
  int two;
} label;

enum type {T_VOID, T_INT, T_FLOAT};

#endif
