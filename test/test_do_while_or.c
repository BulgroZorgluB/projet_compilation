int f() {
  int i;
  int j;
  int n;
  i = 10;
  j = 42;
  n = 0;
  do {
    n = n + 1;
    i = i - 1;
  } while (i > 0 || i !=j);
  return n;
}
