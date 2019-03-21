#ifndef   TS_HACK_H
  #define TS_HACK_H
  //#define USE_INTERFACE 1
  #include "scheme.h"
  #include "scheme-private.h"
  #include "dynload.h"

  /* definition from scheme.c */
  #define car(p) ((p)->_object._cons._car)
  #define cdr(p) ((p)->_object._cons._cdr)

  /* definition from scheme.c */
  #define InitFile "init.scm"

  /* definition from scheme.c */
  #define T_MASKTYPE     31
  #define T_SYNTAX     4096 /* 2^12 */
  #define T_IMMUTABLE  8192 /* 2^13 */
  #define T_ATOM      16384 /* 2^14 */

  /* original definition for convenience */
  #define T_MASK      (T_SYNTAX | T_IMMUTABLE | T_ATOM)

  /* definition from scheme.c */
  enum scheme_types {
    T_STRING           =  1,
    T_NUMBER           =  2,
    T_SYMBOL           =  3,
    T_PROC             =  4,
    T_PAIR             =  5,
    T_CLOSURE          =  6,
    T_CONTINUATION     =  7,
    T_FOREIGN          =  8,
    T_CHARACTER        =  9,
    T_PORT             = 10,
    T_VECTOR           = 11,
    T_MACRO            = 12,
    T_PROMISE          = 13,
    T_ENVIRONMENT      = 14,
    T_LAST_SYSTEM_TYPE = 14
  };

  /* definition from scheme.c */
  extern pointer reverse_in_place(scheme *sc, pointer term, pointer list);
#endif
