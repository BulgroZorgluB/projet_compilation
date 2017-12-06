 #define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include "conv_hex.h"

char *float_to_hex(float f)
{
  char *s = NULL;
  union {
    double a;
    long long int b;
  } u;
  u.a = (double) f;
  asprintf(&s, "0x%016llX", u.b);
  return s;
}

char *double_to_hex(double d)
{
  char *s = NULL;
  union {
    double a;
    long long int b;
  } u;
  u.a = d;
  asprintf(&s, "0x%016llX", u.b);
  return s;
}
