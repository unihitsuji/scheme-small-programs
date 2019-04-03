#include "tscurses.h"

WINDOW *stdscr;
pointer stdscr_cell;

void print_info(char *msg, pointer pw, int y, int x) {
  WINDOW *w = (WINDOW *)ivalue(pw);
  char str[64];
  sprintf(str, "%-10.10s: WINDOW * = x%10lx / cell for WINDOW * = x%10lx", msg, (long)w, (long)pw);
  move(y, x);
  addstr(str);
}

pointer ts_initscr(scheme *sc, pointer args) {
  stdscr = initscr();
  stdscr_cell = mk_integer(sc, (long)stdscr);
  setimmutable(stdscr_cell);
  print_info("ts_initscr", stdscr_cell, 0, 20);
  return stdscr_cell;
}

pointer ts_endwin(scheme *sc, pointer args) {
  return mk_integer(sc, endwin());
}

pointer ts_isendwin(scheme *sc, pointer agrs) {
  if (endwin() == TRUE) return sc->T;
  return sc->F;
}

pointer ts_start_color(scheme *sc, pointer args) {
  return mk_integer(sc, start_color());
}

pointer ts_getch(scheme *sc, pointer args) {
  return mk_integer(sc, getch());
}

pointer ts_wmove(scheme *sc, pointer args) {
  pointer pw = pair_car(args);
  pointer py = pair_car(pair_cdr(args));
  pointer px = pair_car(pair_cdr(pair_cdr(args)));
  if (is_integer(py) && is_integer(px)) {
    print_info("ts_wmove", pw, 1, 20);
    int res = wmove((WINDOW *)ivalue(pw), ivalue(py), ivalue(px));
    return mk_integer(sc, res);
  }
  return sc->NIL;
}

pointer ts_move(scheme *sc, pointer args) {
  pointer py = pair_car(args);
  pointer px = pair_car(pair_cdr(args));
  if (is_integer(py) && is_integer(px)) {
    int res = wmove(stdscr, ivalue(py), ivalue(px));
    return mk_integer(sc, res);
  }
  return sc->NIL;
}

pointer ts_addstr(scheme *sc, pointer args) {
  if (is_string(pair_car(args))) {
    char *str = string_value(pair_car(args));
    return mk_integer(sc, addstr(str));
  }
  return sc->NIL;
}

void init_tscurses(scheme *sc) {
  scheme_define(sc, sc->global_env, mk_symbol(sc, "initscr" )    , mk_foreign_func(sc, ts_initscr));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "endwin")      , mk_foreign_func(sc, ts_endwin));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "isendwin")    , mk_foreign_func(sc, ts_isendwin));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "start_color") , mk_foreign_func(sc, ts_start_color));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "getch")       , mk_foreign_func(sc, ts_getch));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "wmove")       , mk_foreign_func(sc, ts_wmove));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "move")        , mk_foreign_func(sc, ts_move));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "addstr")      , mk_foreign_func(sc, ts_addstr));
}
