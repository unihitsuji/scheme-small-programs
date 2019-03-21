#ifndef   TSREPL_H
  #define TSREPL_H
  #include <stdio.h>
  #include <stdlib.h>
  #include <unistd.h>
  #include "scheme.h"
  #include "scheme-private.h"
  #include "dynload.h"
  extern void init_tsrepl(scheme *sc);
  /*  maybe unnecessary, but harmless  */
  extern pointer ts_repl(scheme *sc, pointer args);
#endif
