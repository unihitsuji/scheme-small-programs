#include "tsbase.h"

pointer ts_chdir(scheme *sc, pointer args) {
  if (args != sc->NIL) {
    if (is_string(pair_car(args)))  {
      char *str = string_value(pair_car(args));
      if (0 == chdir(str)) return pair_car(args);
    }
  }
  return sc->NIL;
}

pointer ts_getcwd(scheme *sc, pointer args) {
  size_t len = 1024;
  char buf[len];
  memset(buf, '\0', len);
  if (NULL != getcwd(buf, len)) return mk_string(sc, buf);
  return sc->NIL;
}

pointer ts_getenv(scheme *sc, pointer args) {
  if (args != sc->NIL) {
    if (is_string(pair_car(args)))  {
      char *key = string_value(pair_car(args));
      char *val = getenv(key);
      if (val != NULL) return mk_string(sc, val);
    }
  }
  return sc->NIL;
}

pointer ts_raw(scheme *sc, pointer args) {
  if (args != sc->NIL) {
    return pair_car(args);
  } else {
    return sc->NIL;
  }
}
/*
pointer ts_load_file(scheme *sc, pointer args) {
  char *str = NULL;
  if (args != sc->NIL) {
    if (is_string(pair_car(args)))  {
      char *fn = string_value(pair_car(args));
      #ifndef RELEASE
      disp4flow("ts_load_file", "try load_file", fn);
      #endif
      if (0 == load_file(sc, fn)) {
        #ifndef RELEASE
	disp4flow("ts_load_file", "ok! load_file", fn);
        #endif
	return pair_car(args);
      }
      #ifndef RELEASE
      disp4flow("ts_load_file", "NG! load_file", fn);
      #endif
    }
  }
  return sc->F;
}
*/
void init_tsbase(scheme *sc) {
  scheme_define(sc, sc->global_env, mk_symbol(sc, "chdir" )   , mk_foreign_func(sc, ts_chdir));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "getcwd")   , mk_foreign_func(sc, ts_getcwd));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "getenv")   , mk_foreign_func(sc, ts_getenv));
  scheme_define(sc, sc->global_env, mk_symbol(sc, "raw")      , mk_foreign_func(sc, ts_raw));
  //scheme_define(sc, sc->global_env, mk_symbol(sc, "load-file"), mk_foreign_func(sc, ts_load_file));
}
