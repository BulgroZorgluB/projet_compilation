#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "list_of.h"

list_of *init_list(enum elem_type e_t) {
  list_of *l;
  l = malloc(sizeof(list_of));
  l->e_t = e_t;
  l->size = 0;
  l->size_max = 0;
  return l;
}

list_of *alloc(list_of *l) {
  if (l->size_max == 0) { 
    l->nodes = malloc(sizeof(node));
    l->size_max++;
  } 
  else {
    l->nodes = realloc(l->nodes, sizeof(node) * l->size_max * 2);
      l->size_max *= 2;
  }
  return l;
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

void init_node(node *n) {
  n->size = 0;
  n->size_max = 0;
}

list_of* add_symbol_node(list_of *l, enum type t, sid name) {
  symbol s;
  s.name = strdup(name);
  s.type = t;
  l = alloc(l);
  init_node(&(l->nodes[l->size]));
  l->nodes[l->size].s = s;
  
  l->size++;
  return l;
}

list_of* add_registre_node(list_of *l, registre r, symbol_id *name) {
  l = alloc(l);
  l->nodes[l->size].r = r;
  l->nodes[l->size].name = name;
  l->size++;
  return l;
}

void add_argument_node(list_of *l, enum type t, sid name) {
  symbol s;
  s.name = strdup(name);
  s.type = t;
  argument_alloc(&(l->nodes[l->size - 1]));
  node *n = &(l->nodes[l->size - 1]);
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

int function_index(list_of *l, sid name) {
  int i = 0;
  int n = l->size;
  while ( i < n) {
    symbol s = l->nodes[i].s;
    if(strcmp(s.name, name) == 0) {
      return i;
    }
    ++i;
  }
  return -1;
}

