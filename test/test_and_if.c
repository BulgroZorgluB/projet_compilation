int f() {
  int a;
  int b;
  int c;
  a = 2;
  b = 3;
  c = 4;
  if (a > b && a < 2*b && a+b<c) {
    a = 7;
  } else {
    a = 12;
  }
  return a;
}

