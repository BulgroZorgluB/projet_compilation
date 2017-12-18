#ifndef _LIST_OF_H
#define _LIST_OF_H

#include "utile.h"

enum elem_type {SYMBOL, REGISTER};

typedef struct node_list_of node;

struct node_list_of{
  registre r;
  symbol_id *name;
  symbol s;
  node *arguments;
  int size;
  int size_max;
};

typedef struct {
  enum elem_type e_t;
  node *nodes;
  int size;
  int size_max;
} list_of;

list_of *init_list(enum elem_type e_t);

void re_init(list_of *l);

list_of *add_symbol_node(list_of *l, enum type t, sid name);

list_of *add_registre_node(list_of *l, registre r, symbol_id *name);

void add_argument_node(list_of *l, enum type t, sid name);

void free_list(list_of *l);

void display_list_of(list_of *l);

void display_registre(registre r);

void display_function(node n);

int function_index(list_of *l, sid name);

#endif //_LIST_OF_H
