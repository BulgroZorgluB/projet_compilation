#ifndef _LINKED_LIST_H
#define _LINKED_LIST_H

#include "utile.h"

struct linked_list{
  struct linked_list *next;
  elem value;
};


void create_list();

void destroy_list();

void add_head(elem value);

void remove_head();

struct linked_list* get_head();

void add_next(struct linked_list* cell, elem value);

void remove_next(struct linked_list* cell);

void remove_until_end(struct linked_list* cell);

struct linked_list* search_until_end(struct linked_list* start, elem value);

elem search_elem_until_end (struct linked_list* start, sid symbol_name);

elem search_elem_between(struct linked_list* start, struct linked_list* end, sid symbol_name);

void set_value (struct linked_list* cell, elem value);

int cmp_value (elem e, elem v);

int cmp_symbol_name(char * name_e, char * name_v);
/*
void remove_value (struct linked_list* cell);
*/
void display_list();

void display_symbol_id(symbol_id *e);
#endif //_LINKED_LIST_H
