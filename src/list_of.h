#ifndef _LIST_OF_H
#define _LIST_OF_H

#include "utile.h"

enum elem_type {SYMBOL, REGISTER};

typedef struct {
  registre r;
  symbol s;
  node *arguments;
  int size;
  int size_max;
} node;

typedef struct {
  enum elem_type e_t;
  node *nodes;
  int size;
  int size_max;
} list_of;

void init_list(list_of *l, enum elem_type e_t);

void add_symbol_node(list_of *l, enum type t, sid name);

void add_registre_node(list_of *l, registre r);

void add_argument_node(list_of *l, node *n, enum type t, sid name);

void free_node(list_of *l);



#endif //_LIST_OF_H
