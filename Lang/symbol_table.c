#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "symbol_table.h"

static struct symbol_table *table = NULL;

void create_table() {
  table = malloc(sizeof(struct symbol_table));
  create_list();
  table->symbol_list = get_head();
  table->last_symbol = get_head();
  table->depth_bloc = 0;
  table->depth_control = 0;
  table->number_bloc = 0;
}

void destroy_table() {
  destroy_list();
  free(table);
  table = NULL;
}

struct symbol_table *get_table() {
  return table;
}

void add_symbol(elem new_elem) {
  if( table->last_symbol == (table->last_symbol)->next) {
    add_head(new_elem);
    table->last_symbol = get_head();
  }
  else {
    add_next(table->last_symbol, new_elem);
    table->last_symbol = (table->last_symbol)->next;
  }
}

void remove_symbol(elem rm_elem) {
  struct linked_list * current = get_head();
  if(current != current->next) {
    if(cmp_value(current->value, rm_elem)) {
      remove_head();
    }
    else {
      while(current->next != (current->next)->next) {
	if(cmp_value((current->next)->value, rm_elem)) {
	  remove_next(current);
	  break;
	}
	else {
	  current = current->next;
	}
      }
    }
  }
}

void add_bloc() {
  table->pointer_bloc[table->depth_bloc] = table->last_symbol;
  table->depth_bloc++;
  table->number_bloc++;
}

void remove_bloc() {
  if( table->depth_bloc != 0) {    
    table->depth_bloc--;
    table->last_symbol = table->pointer_bloc[table->depth_bloc];
    remove_until_end(table->last_symbol);
  }
}

int search_symbol_in_bloc(elem x) {
  struct linked_list *symbol = search_until_end(table->pointer_bloc[table->depth_bloc - 1 - table->depth_control], x);
  if(symbol == NULL)
    return 0;
  return 1;
}

symbol_id*  create_symbol_name(sid symbol_name, int number_bloc) {
  symbol_id* new_name = malloc(sizeof(symbol_id));
  new_name->symbol_name = strdup(symbol_name);
  new_name->symbol_bloc = number_bloc;
  return new_name;
}

void delete_symbol_name(sid symbol_name) {
  free(symbol_name);
}

//elem symbolname is equal to "" if nothing was found
elem find_elem_from_name(sid symbol_name) {
  elem symbol;
  symbol.symbol_name = NULL;
  symbol.symbol_type = T_VOID;
  symbol = search_elem_until_end(table->pointer_bloc[table->depth_bloc - 1 - table->depth_control], symbol_name);
  return symbol;
}

elem create_elem(sid symbol_name, enum type symbol_type) {
  elem new_elem;
  new_elem.symbol_name = create_symbol_name(symbol_name, table->number_bloc);
  new_elem.symbol_type = symbol_type;
  return new_elem;
}



void increment_depth_control() {
  table->depth_control++;
}

void decrement_depth_control() {
  table->depth_control--;
}

enum type type_last_bloc() {
  return (((table->pointer_bloc[table->depth_bloc - 1 - table->depth_control])->value).symbol_type);
}
