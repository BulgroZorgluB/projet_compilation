int f() {
  int a;
  int b;
  a = 0;
  b = 10;
  while (a < 10) do {
      a = a + 1;
      while (a+b < 30) do {
	  b = b + 1;
	}
      b = b - 15;
    }
  return a;
}
