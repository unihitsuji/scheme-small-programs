#ifndef   TSBASE_H
  #define TSBASE_H
  #include <stdio.h>
  #include <stdlib.h>
  #include <unistd.h>
  #include "scheme.h"
  #include "scheme-private.h"
  #include "dynload.h"
  extern void init_tsbase(scheme *sc);
  /*  maybe unnecessary, but harmless  */
  extern pointer ts_chdir(scheme *sc, pointer args);
  extern pointer ts_getcwd(scheme *sc, pointer args);
  extern pointer ts_getenv(scheme *sc, pointer args);
  extern pointer ts_raw(scheme *sc, pointer args);
#endif
