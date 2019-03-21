#include "tool.h"
#include "ts-tool.h"
#include "tsbase.h"
#include "tsrepl.h"

pointer ts_load_file(scheme *sc, pointer args) {
  char *str = NULL;
  if (args != sc->NIL) {
    if (is_string(pair_car(args)))  {
      char *fn = string_value(pair_car(args));
      #ifndef RELEASE
      //disp4flow("ts_load_file", "try load_file", fn);
      #endif
      if (0 == load_file(sc, fn)) {
        #ifndef RELEASE
	//disp4flow("ts_load_file", "ok! load_file", fn);
        #endif
	return pair_car(args);
      }
      #ifndef RELEASE
      //disp4flow("ts_load_file", "NG! load_file", fn);
      #endif
    }
  }
  return sc->F;
}

int main(int argc, char **argv) {
  scheme *sc;
  pointer args;
  char *env_val;
  int ret;
  FILE *fp;

  sc = scheme_init_new();
  args = sc->NIL;
  scheme_set_input_port_file(sc, stdin);
  scheme_set_output_port_file(sc, stdout);

  //scheme_define(sc, sc->global_env, mk_symbol(sc, "dispstr"), mk_foreign_func(sc, ts_dispstr));
  //scheme_define(sc, sc->global_env, mk_symbol(sc, "display"), mk_foreign_func(sc, ts_dispstr));

  init_tsbase(sc);
  init_tsrepl(sc);
  //scheme_define(sc, sc->global_env, mk_symbol(sc, "chdir")     , mk_foreign_func(sc, ts_chdir));
  //scheme_define(sc, sc->global_env, mk_symbol(sc, "getcwd")    , mk_foreign_func(sc, ts_getcwd));
  //scheme_define(sc, sc->global_env, mk_symbol(sc, "getenv")    , mk_foreign_func(sc, ts_getenv));
  //scheme_define(sc, sc->global_env, mk_symbol(sc, "raw")       , mk_foreign_func(sc, ts_raw));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "load-file") , mk_foreign_func(sc, ts_load_file));

  if (NULL != (env_val = getenv("TINYSCHEMEINIT"))) {
    if (NULL != (fp = fopen(env_val, "r"))) {
      scheme_load_file(sc, fp);
    } else {
      load_lib(sc, InitFile, "");
    }
  } else {
    load_lib(sc, InitFile, "");
  }

  //  NOTE: not strchr(string.h)
  load_lib(sc, strrchar(argv[0], '/'), ".scm");

  if (argc > 1) {
    /* optional arguments */
    if (strcmp(argv[1], "-1") == 0) {
      char **argv3 = argv + 3;
      for (; *argv3; argv3++) {
	pointer val = mk_string(sc, *argv3);
	args = cons(sc, val, args);
      }
      args = reverse_in_place(sc, sc->NIL, args);
      scheme_define(sc, sc->global_env, mk_symbol(sc, "*args*"), args);
      if (0 != load_file(sc, argv[2])) {
	disp4flow("main", "NG! load_file", argv[2]);
      }
    } else {
      for (int i = 1; i < argc; i++) {
        if (0 != load_file(sc, argv[i])) {
          disp4flow("main", "NG! load_file", argv[i]);
        }
      }
    }
  } else {
    /* no argument */
    scheme_load_named_file(sc, stdin, NULL);
    ret = sc->retcode;
  }
  printf("\n");
  scheme_deinit(sc);
  return ret;
}
