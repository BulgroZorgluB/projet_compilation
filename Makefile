SOURCE = src
TEST = test
RESULTAT = resultat

.PHONY	: src_make test_make resultat_make

all	: src_make test_make resultat_make

src_make:
	$(MAKE) -sC $(SOURCE)

test_make: src_make
	$(MAKE) -sC $(TEST)

resultat_make: src_make
	$(MAKE) -sC $(RESULTAT)

clean: 
	$(MAKE) -sC $(SOURCE) clean
	$(MAKE) -sC $(TEST) clean 
	$(MAKE) -sC $(RESULTAT) clean
