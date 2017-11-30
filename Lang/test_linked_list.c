#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "linked_list.h"

void test_create_destroy_list() {
  struct linked_list * head = get_head();
  assert(head == NULL);
  create_list();
  head = get_head();
  assert(head != NULL);
  assert(head->next != NULL);
  assert(head == head->next);
  
  destroy_list();

  head = get_head();
  assert(head == NULL);
}

void test_add_remove_head() {
  create_list();
  struct linked_list * head = get_head();
  elem value;
  value.symbol_type = T_VOID;
  add_head(value);
  assert((head->value).symbol_type == T_VOID);

  remove_head();
  head = get_head();
  assert(head != NULL);
  assert(head == head->next);
  destroy_list();
}

void test_add_remove_next() {
  create_list();
  struct linked_list *head = get_head();
  elem value;
  value.symbol_type = T_VOID;
  add_head(value);
  head = get_head();
  add_next(head,value);

  assert(head->next != head->next->next);
  assert(((head->next)->value).symbol_type == T_VOID);

  remove_next(head);
  assert(head->next == head->next->next);
  remove_next(head);
  assert(head->next == head->next->next);
  destroy_list();
}

void test_remove_until_end() {
  create_list();
  struct linked_list * head = get_head();
  elem value;
  remove_until_end(head);

  add_head(value);
  head = get_head();
  remove_until_end(head);

  add_next(head,value);
  add_next(head,value);
  add_next(head,value);

  assert(head->next != head->next->next);
  remove_until_end(head);
  assert(head->next == head->next->next);
  
  destroy_list();
}

void test_search_until_end() {
  create_list();  
  struct linked_list * head = get_head();
  
  char * a = "aaa";
  char * b = "bbb";
  char * c = "ccc";

  elem value[3];
  value[0].symbol_name = a;
  value[0].symbol_type = T_VOID;

  value[1].symbol_name = b;
  value[1].symbol_type = T_VOID;

  value[2].symbol_name = c;
  value[2].symbol_type = T_VOID;

  add_head(value[0]);
  head = get_head();

  add_next(head,value[1]);
  add_next(head,value[1]);
  add_next(head,value[0]);

  assert(search_until_end(head, value[0]) != NULL);
  assert(search_until_end(head, value[1]) != NULL);
  assert(search_until_end(head, value[2]) == NULL); 
  
  destroy_list();
}

void test_cmp_value() {
  char * a = "aaa";
  char * b = "bbb";
  char * c = "ccc";

  elem value[4];
  value[0].symbol_name = a;
  value[0].symbol_type = T_VOID;

  value[1].symbol_name = a;
  value[1].symbol_type = T_INT;

  value[2].symbol_name = c;
  value[2].symbol_type = T_VOID;

  value[3].symbol_name = a;
  value[3].symbol_type = T_VOID;


  assert(cmp_value(value[0], value[0]) == 1);
  assert(cmp_value(value[0], value[1]) == 0);
  assert(cmp_value(value[0], value[2]) == 0);
  assert(cmp_value(value[0], value[3]) == 1);
}


int main() {
  test_create_destroy_list();
  test_add_remove_head();
  test_add_remove_next();
  test_remove_until_end();
  test_search_until_end();
  test_cmp_value();
  return 0;
}
