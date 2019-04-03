#ifndef   TSCURSES_H
  #define TSCURSES_H
  #include <ncurses.h>
  #include "scheme.h"
  #include "scheme-private.h"
  #include "dynload.h"
  extern pointer ts_initscr(scheme *sc, pointer args);
  extern pointer ts_endwin(scheme *sc, pointer args);
  extern pointer ts_getch(scheme *sc, pointer args);
  extern pointer ts_isendwin(scheme *sc, pointer args);
  extern pointer ts_start_color(scheme *sc, pointer args);
  extern pointer ts_wmove(scheme *sc, pointer args);
  extern pointer ts_move(scheme *sc, pointer args);
  extern pointer ts_addstr(scheme *sc, pointer args);
  extern void init_tscurses(scheme *sc);
#endif
