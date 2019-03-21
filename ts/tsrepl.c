#include "tsrepl.h"

void print_info(scheme *sc, const char *msg) {
  char *str;
  if (msg == NULL) {
    str = "";
  } else {
    str = (char *)msg;
  }
  fprintf(stderr, "%s sc->NIL   = %lx / sc->T = %lx / sc->F = %lx\n", str, (long)sc->NIL, (long)sc->T, (long)sc->F);
  fprintf(stderr, "%s sc->envir = %lx\n", str, (long)sc->envir);
}

void print_port(scheme *sc, char *s, pointer p) {
  fprintf(stderr, "=========1=========2=========3=========4=========5=========6=========7=========\n");
  fprintf(stderr, "%s                                    = x%lx\n", s, (long)p);
  fprintf(stderr, "%s->_object._port                     = x%lx\n", s, (long)p->_object._port);
  fprintf(stderr, "%s->_object._port->kind               = x%x\n" , s, (int)p->_object._port->kind);
  fprintf(stderr, "%s->_object._port->rep.stdio.closeit  = x%x\n" , s, p->_object._port->rep.stdio.closeit);
  if (p->_object._port->rep.stdio.file == stdin) {
       fprintf(stderr, "%s->_object._port->rep.stdio.file     = stdin  x%lx\n", s, (long)p->_object._port->rep.stdio.file);
  } else if (p->_object._port->rep.stdio.file == stdout) {
       fprintf(stderr, "%s->_object._port->rep.stdio.file     = stdout x%lx\n", s, (long)p->_object._port->rep.stdio.file);
  } else {
       fprintf(stderr, "%s->_object._port->rep.stdio.filename = %s\n", s, p->_object._port->rep.stdio.filename);
  }
}

pointer ts_repl(scheme *sc, pointer args) {
  pointer saved = sc->inport;
  print_info(sc, "ts_repl:");
  //sc->inport->_object._port->rep.stdio.closeit = 0;
  //scheme_set_input_port_file(sc, stdin);
  //scheme_set_output_port_file(sc, stdout);
  //print_port(sc, "ts_repl after : saved"       , saved);
  //print_port(sc, "ts_repl init  : inport"      , sc->inport);
  //print_port(sc, "ts_repl init  : outport"     , sc->outport);
  //print_port(sc, "ts_repl init  : save_inport" , sc->save_inport);
  //print_port(sc, "ts_repl init  : loadport"    , sc->loadport);
  fprintf(stderr, "REPL %d ENTER", sc->nesting);
  scheme_load_named_file(sc, stdin, NULL);         // CORE
  //scheme_set_input_port_file(sc, stdin);
  //scheme_set_output_port_file(sc, stdout);
  //print_port(sc, "ts_repl after : saved"       , saved);
  //print_port(sc, "ts_repl init  : inport"      , sc->inport);
  //print_port(sc, "ts_repl init  : outport"     , sc->outport);
  //print_port(sc, "ts_repl init  : save_inport" , sc->save_inport);
  //print_port(sc, "ts_repl init  : loadport"    , sc->loadport);
  sc->inport = saved;
  fprintf(stderr, "REPL %d QUIT with retcode %d\n", sc->nesting, sc->retcode);
  //if (0 == sc->retcode) return sc->value;
  return sc->NIL;
}

void init_tsrepl(scheme *sc) {
  scheme_define(sc, sc->global_env, mk_symbol(sc, "repl")     , mk_foreign_func(sc, ts_repl));
}
