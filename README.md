### PROJET DE COMPILATION ###
Ce dépot contient le projet de compilation réalisé par Baptiste Vergain et Luc Boissieras

### GUIDE D'UTILISATION ###

make: creer l'executable dans le dossier bin/ avec les sources dans le dossier src/

make test_make: creer les fichiers llvm pour le dossier test/

make resultat_make: creer les fichiers llvm pour le dossier resultat/

make clean: lance le clean pour les 3 parties du projet (src, test, resultat);

./compil.sh $1: lance la compilation(si l'executable est existant) du fichier $1.c avec $1.ll en sortie et $1.txt qui contient les erreurs.

chaque compilation d'un fichier c en llvm génère un fichier d'erreur qui contient les erreurs( il est donc vide si la compilation du fichier c'est bien passée)

