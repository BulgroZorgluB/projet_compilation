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
    realloc(l->nodes, sizeof(node) * l->size_max * 2);
    l->size_max *= 2;
  }
}

void argument_alloc(node *n) {
  if (n->size_max == 0) { 
    n->arguments = malloc(sizeof(node));
    l->size_max++;
  } 
  else {
    realloc(n->arguments, sizeof(node) * n->size_max * 2);
    n->size_max *= 2;
  }
}

void add_symbol_node(list_of *l, enum_type t, sid name) {
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
  n->arguments[n->size] = s;
  n->size++
}

void free_node(list_of *l) {

}


