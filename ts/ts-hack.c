#include "ts-hack.h"

/*  from scheme.c  */
pointer reverse_in_place(scheme *sc, pointer term, pointer list) {
  pointer p = list, result = term, q;
  while (p != sc->NIL) {
    q = cdr(p);
    cdr(p) = result;
    result = p;
    p = q;
  }
  return result;
}
