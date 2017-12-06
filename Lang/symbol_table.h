#ifndef _SYMBOL_TABLE_H
#define _SYMBOL_TABLE_H

#include "linked_list.h"

#define POOL_SIZE 50

struct symbol_table {
  struct linked_list *symbol_list;
  struct linked_list *last_symbol;
  struct linked_list *pointer_bloc[POOL_SIZE];
  int depth_bloc;
  int depth_control;
  int number_bloc;
};

void create_table();

void destroy_table();

struct symbol_table *get_table();

void add_symbol(elem new_elem);

void remove_symbol(elem rm_elem);

void add_bloc();

void remove_bloc();

int search_symbol_in_bloc(elem x);

enum type find_type_from_name(sid symbol_name);

elem create_elem(sid symbol_name, enum type symbol_type);

void increment_depth_control();

void decrement_depth_control();

enum type type_last_bloc();



#endif //_SYMBOL_TABLE_H
