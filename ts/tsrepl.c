#include "tsrepl.h"

static int nest = 0;

void print_info(scheme *sc, const char *msg) {
  char *str = "", *env = "";
  if (msg != NULL) str = (char *)msg;
  if (sc->global_env == sc->envir) env = " = global_env";
  fprintf(stderr, "%s REPL nest = %d\n", str, nest);
  fprintf(stderr, "%s sc->NIL = x%lx / sc->T = x%lx / sc->F = x%lx\n", str, (long)sc->NIL, (long)sc->T, (long)sc->F);
  fprintf(stderr, "%s sc->global_env = x%lx / sc->envir = x%lx%s\n", str, (long)sc->global_env, (long)sc->envir, env);
  fprintf(stderr, "%s sc->file_i = %d / sc->nesting = %d\n", str, sc->file_i, sc->nesting);
  fprintf(stderr, "%s +---+-------------------------+-----------------+\n", str);
  fprintf(stderr, "%s |   |     sc->load_stack      |sc->nesting_stack|\n", str);
  fprintf(stderr, "%s |idx|port        kind what    |                 |\n", str);
  fprintf(stderr, "%s +---+-------------------------+-----------------+\n", str);
  for (int i = 0; i <= sc->file_i; i++) {
    struct port *p = &sc->load_stack[i];
    char *what = "";
    if (p->kind == 0) what = "free";
    if ((p->kind & port_file)   && p->rep.stdio.file == stdin ) what = "stdin";
    if ((p->kind & port_file)   && p->rep.stdio.file == stdout) what = "stdout";
    if (p->kind & port_string) what = "string";
    fprintf(stderr, "%s |%3d|x%10lx x%03x %-6s  |x%08x        |\n", str, i, (long)p, p->kind, what, sc->nesting_stack[i]);
  }
  fprintf(stderr, "%s +---+-------------------------+-----------------+\n", str);
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

pointer ts_print_context(scheme *sc, pointer args) {
  print_info(sc, "ts_print_context:");
  if (sc->inport == sc->save_inport && sc->inport == sc->loadport) {
    fprintf(stderr, "ts_print_context: inport == save_inport == loadport\n");
  }
  if (sc->inport == sc->save_inport && sc->inport != sc->loadport) {
    fprintf(stderr, "ts_print_context: inport == save_inport != loadport\n");
  }
  if (sc->inport != sc->save_inport && sc->inport == sc->loadport) {
    fprintf(stderr, "ts_print_context: inport == loadport != save_inport\n");
  }
  if (args == sc->NIL) {
    print_port(sc, "ts_print_context: inport"      , sc->inport);
    print_port(sc, "ts_print_context: save_inport" , sc->save_inport);
    print_port(sc, "ts_print_context: loadport"    , sc->loadport);
    print_port(sc, "ts_print_context: outport"     , sc->outport);
  } else if (is_symbol(args->_object._cons._car)) {
    pointer car = args->_object._cons._car;
    if ( (long)car ==  (long)mk_symbol(sc, "inport") ) {
      print_port(sc, "ts_print_context: inport"      , sc->inport);
    } else if ( (long)car == (long)mk_symbol(sc, "save_inport") ) {
      print_port(sc, "ts_print_context: save_inport" , sc->save_inport);
    } else if ( (long)car == (long)mk_symbol(sc, "loadport") ) {
      print_port(sc, "ts_print_context: loadport"    , sc->loadport);
    } else if ( (long)car == (long)mk_symbol(sc, "outport") ) {
      print_port(sc, "ts_print_context: outport"     , sc->outport);
    }
  }
  if (0 == sc->retcode) return sc->value;
  return sc->NIL;
}

pointer ts_repl(scheme *sc, pointer args) {
  pointer saved_inport   = sc->inport;
  pointer saved_loadport = sc->loadport;
  nest++;
  //fprintf(stderr, "REPL %d ENTER", nest);
  scheme_load_named_file(sc, stdin, NULL);         // CORE
  sc->inport   = saved_inport;
  sc->loadport = saved_loadport;
  nest--;
  //fprintf(stderr, "REPL %d QUIT with retcode %d\n", nest, sc->retcode);
  if (0 == sc->retcode) return sc->value;
  return sc->NIL;
}

void init_tsrepl(scheme *sc) {
  scheme_define(sc, sc->global_env, mk_symbol(sc, "repl")         , mk_foreign_func(sc, ts_repl));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "print-context"), mk_foreign_func(sc, ts_print_context));
}
