
all	: test_variable.ll test_if.ll test_condition.ll test_float.ll test_boucle.ll test_boucle_while.ll 	

%.ll: %.c
	./Lang/prog < $< > $@