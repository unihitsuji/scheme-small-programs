#ifndef   TS_TOOL_H
  #define TS_TOOL_H
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  #include "ts-hack.h"

  #define LOAD_LIB_ENV          "SCHEME_LIBRARY_PATH"
  #define READ_BUF_SIZE          160
  #define EVAL_BUF_SIZE         4096
  #define DISP4FLOW_FUNC_FORMAT "%-16s: "
  #define DISP4FLOW_MSG1_FORMAT "%-22s "
  #define DISP4FLOW_MSG2_FORMAT "%-s\n"

  #define symbol_name(p) ((p)->_object._cons._car->_object._string._svalue)

  /* constants */
  extern const char *str_string;
  extern const char *str_number;
  extern const char *str_symbol;
  extern const char *str_proc;
  extern const char *str_pair;
  extern const char *str_closure;
  extern const char *str_continuation;
  extern const char *str_foreign;
  extern const char *str_character;
  extern const char *str_port;
  extern const char *str_vector;
  extern const char *str_macro;
  extern const char *str_promise;
  extern const char *str_environment;
  extern const char *str_atom;
  extern const char *str_immutable;
  extern const char *str_syntax;
  extern const char *str_empty;
  /* functions */
  extern       void    disp4flow(const char *func, const char *msg1, const char *msg2);
  extern       void    set_error(scheme *sc, const char *msg, pointer a);
  extern       int     is_closed(char *str);
  extern       int     load_string_raw(scheme *sc, char *name);
  extern       int     read_eval(scheme *sc);
  extern       void    print_value(scheme *sc, pointer val, int flag);
  extern       void    print_result(scheme *sc);
  extern       int     load_file(scheme *sc, char *name);
  extern       int     load_env( scheme *sc, char *env_key, char *name, char *ext);
  extern       int     load_lib( scheme *sc, char *name, char *ext);
  extern       int     load_home(scheme *sc, char *name, char *ext);
  extern       int     maxlen(char **strs);
  extern const char   *str4flag(int flag);
  extern       int     is_flag(int flag, int what);
  extern       void    define_list(scheme *sc, char *symbol, char **argv);
#endif
