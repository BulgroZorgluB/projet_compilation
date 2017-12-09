#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "list_of.h"

void init_list(list_of *l, enum elem_type e_t) {
  l = malloc(sizeof(list_of));
  l->e_t = e_t;
  l->size = 0;
  l->size_max = 0;
}

void alloc(list_of *l) {
  if (l->size_max == 0) { 
    l->nodes = malloc(sizeof(node));
    l->size_max++;
  } 
  else {
    l->nodes = realloc(l->nodes, sizeof(node) * l->size_max * 2);
    l->size_max *= 2;
  }
}

void argument_alloc(node *n) {
  if (n->size_max == 0) { 
    n->arguments = malloc(sizeof(node));
    n->size_max++;
  } 
  else {
    n->arguments = realloc(n->arguments, sizeof(node) * n->size_max * 2);
    n->size_max *= 2;
  }
}

void add_symbol_node(list_of *l, enum type t, sid name) {
  symbol s;
  s.name = strdup(name);
  s.type = t;
  alloc(l);
  l->nodes[l->size].s = s;
  l->size++;
}

void add_registre_node(list_of *l, registre r) {
  alloc(l);
  l->nodes[l->size].r = r;
  l->size++;
}

void add_argument_node(node *n, enum type t, sid name) {
  symbol s;
  s.name = strdup(name);
  s.type = t;
  argument_alloc(n);
  n->arguments[n->size].s = s;
  n->size++;
}

void free_list(list_of *l) {
  int i = 0;
  int n = l->size;
  while ( i < n) {
    free(l->nodes[i].arguments);
    ++i;
  }
  free(l->nodes);
  free(l);
}


void display_list_of(list_of *l) {
  int i = 0;
   int n = l->size;
   while ( i < n) {
     if(l->e_t == SYMBOL) {
       display_function(l->nodes[i]);
     }
     else {
       display_registre((l->nodes[i]).r);
     }
     ++i;
   }
 }

 void display_registre(registre r) {
   printf("registre: %d, %d\n",r.reg_id, r.reg_type);
 }

 void display_function(node n) {
   printf("function: %s, %d\n",(n.s).name, (n.s).type);
   int i = 0;
   int size = n.size;
   while (i < size) {
     symbol s = n.arguments[i].s;
    printf("parameters: %s, %d\n",s.name, s.type);
    ++i;
  }
}
