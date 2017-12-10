EXECUTABLE_PATH = ../bin/compiler	

VOID = test_void.ll
INT = test_constante_int.ll test_variable_int.ll
FLOAT = test_constante_float.ll test_variable_float.ll test_sub.ll
CONDITION = test_if.ll test_if_else.ll
BOUCLE = test_while.ll test_do_while.ll
SUB = test_sub.ll
CONVERSION = test_conversion_type.ll
SCOPE = test_declaration_in_different_scope.ll
ERR = test_double_declaration_variable.ll test_not_found_variable.ll

EXECUTABLE_PATH = ../bin/compiler	

.PHONY: all compilateur void int float condition boucle sub err

all	: compilateur void int float condition boucle sub err

void	: $(VOID)

int	: $(INT)

float	: $(FLOAT)

condition	: $(CONDITION)

boucle	: $(BOUCLE)

sub	: $(SUB)

err	: $(ERR)

%.ll: %.c
	$(EXECUTABLE_PATH) < $< 1> $@

clean:
	rm -f *.ll *~ \#*


