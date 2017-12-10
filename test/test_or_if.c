int f() {
  int a;
  int b;
  a = 0;
  b = 10;
  if (a < b || a+b<20 || a-b > 50) {
    a = 5;
  } else {
    a = 7;
  }
  return a;
}
