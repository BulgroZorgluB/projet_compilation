int f() {
  int i;
  int j;
  int n;
  i = 10;
  j = 42;
  n = 0;
  while (i > 0 && j<100) do {
      n = n + 1;
      i = i - 1;
      j = j + 1;
      /*  while (i < j) do {
	  j = j - i;
	  }*/
    }
  return n;
}
