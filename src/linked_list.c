#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "linked_list.h"

static struct linked_list* head = NULL;
static struct linked_list* sentinel = NULL;

void create_list() {
  sentinel = malloc(sizeof(struct linked_list));
  sentinel->next = sentinel;

  head = sentinel;
}

void destroy_list() {
  remove_until_end(head);
  free(head);
  if(sentinel != head) {
    free(sentinel);
  }
  head = NULL;
  sentinel = NULL;
}

void add_head(elem value) {
  struct linked_list * tmp;
  tmp = head;

  head = malloc(sizeof(struct linked_list));
  head->next = tmp;

  set_value(head, value);
}

void remove_head() {
  struct linked_list * tmp;
  tmp = head;
  head = head->next;
  free(tmp);
}


struct linked_list* get_head() {
  return head;
}

void add_next(struct linked_list* cell, elem value) {
  if(cell != sentinel) {
    struct linked_list* cell_next = cell->next;
    struct linked_list* cell_new = malloc(sizeof(struct linked_list));
    set_value(cell_new, value);
    cell_new->next = cell_next;
    cell->next = cell_new;
  }
}

void delete_symbol_id(symbol_id* s_id) {
  free(s_id->symbol_name);
  free(s_id);
}

void remove_next(struct linked_list* cell) {
  struct linked_list* cell_next = cell->next;
  if (cell->next != cell && cell_next != sentinel) {
    cell->next = cell_next->next;
    delete_symbol_id((cell_next->value).symbol_name);
    free(cell_next);
  }
}

void remove_until_end(struct linked_list* cell) {
  while( cell->next != cell->next->next) {
    remove_next(cell);
  }
}

struct linked_list* search_until_end(struct linked_list* start, elem value) {
  while(start != start->next) {
    if(cmp_value(start->value, value)) {
      return start;
    }
    start = start->next;
  }
  return NULL;
}

elem search_elem_until_end (struct linked_list* start, sid symbol_name) {
  elem value;
  value.symbol_name = NULL;
  value.symbol_type = T_VOID;
  while(start != start->next) {
    if(cmp_symbol_name((start->value).symbol_name->symbol_name, symbol_name) == 0) {
      value.symbol_name = (start->value).symbol_name;
      value.symbol_type = (start->value).symbol_type;
    }
    start = start->next;
  }
  return value;
}

elem search_elem_between(struct linked_list* start, struct linked_list* end, sid symbol_name) {
  elem value;
  value.symbol_name = NULL;
  value.symbol_type = T_VOID;
  while(start != end) {
    if(cmp_symbol_name((start->value).symbol_name->symbol_name, symbol_name) == 0) {
      value.symbol_name = (start->value).symbol_name;
      value.symbol_type = (start->value).symbol_type;
    }
    start = start->next;
  }
  display_symbol_id(value.symbol_name);
  return value;
}


void set_value (struct linked_list* cell, elem value) {
  (cell->value).symbol_name = value.symbol_name;
  (cell->value).symbol_type = value.symbol_type;
}

int cmp_value(elem e, elem v) {
  if((cmp_symbol_name(e.symbol_name->symbol_name, v.symbol_name->symbol_name) == 0) && (v.symbol_type == e.symbol_type) ) {
    return 1;
  }
  return 0;
}

int cmp_symbol_name(char* name_e, char* name_v) {
  return strcmp(name_e, name_v);
}
/*
void remove_value (struct linked_list* cell) {
  cell->value = NULL;
}
*/

void display_list() {
  struct linked_list * start = head;
  while(start != start->next) {
    printf("%d,",start->value.symbol_type);
    display_symbol_id(start->value.symbol_name);
    printf("\n");
    start = start->next;
  }
}

void display_symbol_id(symbol_id *e) {
  printf("%s.%d", e->symbol_name, e->symbol_bloc);
}

