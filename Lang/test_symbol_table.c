#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#include "symbol_table.h"

void test_create_destroy_table() {
  assert(get_table() == NULL);
  create_table();

  struct symbol_table *table = get_table();
  assert(table != NULL);
  assert(table->symbol_list != NULL);
  assert(table->depth_bloc == 0);

  destroy_table();
  table = get_table();
  assert(table == NULL);
  
}

void test_add_remove_symbol() {
  create_table();
  struct symbol_table *table = get_table();
  elem value[3];
  value[0] = create_elem("aaa", T_INT);

  value[1] = create_elem("bbb", T_INT);

  value[2] = create_elem("ccc", T_VOID);

  add_symbol(value[0]);
  struct linked_list * head = get_head();
  assert(table->last_symbol == head);
  assert(head->next != head);

  add_symbol(value[1]);
  assert(table->last_symbol != head);
  remove_symbol(value[2]);
  remove_symbol(value[0]);
  assert(table->last_symbol != head);
  add_symbol(value[0]);

  remove_symbol(value[0]);
  assert(table->last_symbol == head);
  remove_symbol(value[1]);
  remove_symbol(value[1]);
  head = get_head();
  assert(head->next == head);
  destroy_table();
}

void test_add_remove_bloc() {
  create_table();
  struct symbol_table *table = get_table();
  struct linked_list * head = get_head();
  elem value[3];
  value[0] = create_elem("aaa", T_INT);

  value[1] = create_elem("bbb", T_INT);

  value[2] = create_elem("ccc", T_VOID);

  assert(table->last_symbol == head);
  assert(table->depth_bloc == 0);

  add_symbol(value[0]);
  add_bloc();  
  assert(table->pointer_bloc[table->depth_bloc - 1] == table->last_symbol);
  head = get_head();

  assert(table->depth_bloc == 1);


  add_symbol(value[1]);
  add_bloc();
  assert(table->last_symbol != head);
  assert(table->depth_bloc == 2);
  assert(table->pointer_bloc[table->depth_bloc - 1] == table->last_symbol);
  assert(table->pointer_bloc[table->depth_bloc - 1] != table->pointer_bloc[(table->depth_bloc) - 2]);

  remove_bloc();
  assert(table->last_symbol != head);
  assert(table->depth_bloc == 1);
  assert(table->pointer_bloc[table->depth_bloc] == table->last_symbol);

  remove_bloc();
  assert(table->last_symbol == head);
  assert(table->depth_bloc == 0);  
}

void test_search_symbol_in_bloc() {
create_table();
  struct symbol_table *table = get_table();
  struct linked_list * head = get_head();
  elem value[6];
  value[0] = create_elem("aaa", T_INT);

  value[1] = create_elem("bbb", T_INT);

  value[2] = create_elem("ccc", T_VOID);

  value[3] = create_elem("f", T_INT);

  value[4] = create_elem("g", T_INT);

  value[5] = create_elem("while", T_VOID);

  add_symbol(value[3]);
  add_bloc();
  assert(search_symbol_in_bloc(value[3]) == 1);
  assert(search_symbol_in_bloc(value[0]) == 0);

  add_symbol(value[0]);
  assert(search_symbol_in_bloc(value[0]) == 1);

  add_symbol(value[4]);
  add_bloc();
  assert(search_symbol_in_bloc(value[3]) == 0);
  assert(search_symbol_in_bloc(value[0]) == 0);
  
  add_symbol(value[1]);
  add_bloc();
  add_symbol(value[5]);
  increment_depth_control();

  add_symbol(value[2]);
  display_list();
  assert(search_symbol_in_bloc(value[1]) == 1);
  assert(search_symbol_in_bloc(value[2]) == 1);

  remove_bloc();
  decrement_depth_control();
  assert(search_symbol_in_bloc(value[1]) == 1);
  assert(search_symbol_in_bloc(value[2]) == 0);
  assert(search_symbol_in_bloc(value[0]) == 0);

  remove_symbol(value[1]);
  assert(search_symbol_in_bloc(value[1]) == 0);
  
  remove_bloc();
  assert(search_symbol_in_bloc(value[3]) == 1);
  assert(search_symbol_in_bloc(value[0]) == 1);
}

int main() {
  test_create_destroy_table();
  test_add_remove_symbol();
  test_add_remove_bloc();
  test_search_symbol_in_bloc();
  return 0;
}
