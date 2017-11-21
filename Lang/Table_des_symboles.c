/*
 *  Table des symboles.c
 *
 *  Created by Janin on 12/10/10.
 *  Copyright 2010 LaBRI. All rights reserved.
 *
 */

#include "Table_des_symboles.h"

#include <stdlib.h>
#include <stdio.h>

#include "utile.h"

/* The storage structure is implemented as a linked chain */

/* linked element def */

typedef struct elem {
  sid symbol_name;
//symb_value_type symbol_type;
  enum type symbol_type;
  struct elem * next;
} elem;

/* linked chain initial element */
static elem * storage=NULL;

/* get the symbol value of symb_id from the symbol table */
enum type get_symbol_type(sid symb_id) {
	elem * tracker=storage;

	/* look into the linked list for the symbol value */
	while (tracker) {
		if (tracker -> symbol_name == symb_id) return tracker -> symbol_type; 
		tracker = tracker -> next;
	}
    
	/* if not found does cause an error */
	fprintf(stderr,"Error : symbol %s have no defined value\n",(char *) symb_id);
	exit(-1);
};

/* set the value of symbol symb_id to value */
enum type set_symbol_type(sid symb_id, enum type value) {

	elem * tracker;
	
	/* (optionnal) check that sid is valid symbol name and exit error if not */
	if (! sid_valid(symb_id)) {
		fprintf(stderr,"Error : symbol id %p is not have no valid sid\n",symb_id);
		exit(-1);
	}
		
	/* look for the presence of symb_id in storage */
	
	tracker = storage;
	while (tracker) {
		if (tracker -> symbol_name == symb_id) {
			tracker -> symbol_type = value;
			return tracker -> symbol_type;
		}
		tracker = tracker -> next;
	}
	
	/* otherwise insert it at head of storage with proper value */
	
	tracker = malloc(sizeof(elem));
	tracker -> symbol_name = symb_id;
	tracker -> symbol_type = value;
	tracker -> next = storage;
	storage = tracker;
	return storage -> symbol_type;
}

