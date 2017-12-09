SOURCE = src
TEST = test
RESULTAT = resultat

.PHONY	: src_make test_make resultat_make

all	: src_make test_make resultat_make

src_make:
	$(MAKE) -sC $(SOURCE)

test_make:
	$(MAKE) -sC $(TEST)

resultat_make:
	$(MAKE) -sC $(RESULTAT)	
