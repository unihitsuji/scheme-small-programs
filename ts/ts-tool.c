#include "tool.h"
#include "ts-tool.h"

//  0: OK
// -1: NG fopen
// -2: NG scheme_load_file
int load_file(scheme *sc, char *fn) {
  FILE *fp;
  if (strcmp(fn, "-") == 0) {
    fp = stdin;
    #ifndef RELEASE
    disp4flow("  load_file", "ok! stdin", fn);
    disp4flow("  load_file", "try scheme_load_file", fn);
    #endif
    scheme_load_file(sc, fp);
    if (sc->retcode != 0) {
      #ifndef RELEASE
      disp4flow("  load_file", "NG! scheme_load_file", fn);
      #endif
      return -2;
    } else {
      #ifndef RELEASE
      disp4flow("  load_file", "ok! scheme_load_file", fn);
      #endif
    }
  } else {
    #ifndef RELEASE
    disp4flow("  load_file", "try fopen", fn);
    #endif
    fp = fopen(fn, "r");
    if (fp == NULL) {
      #ifndef RELEASE
      disp4flow("  load_file", "NG! fopen", fn);
      #endif
      return -1;
    }
    #ifndef RELEASE
    disp4flow("  load_file", "ok! fopen", fn);
    disp4flow("  load_file", "try scheme_load_file", fn);
    #endif
    scheme_load_file(sc, fp);
    if (sc->retcode != 0) {
      #ifndef RELEASE
      disp4flow("  load_file", "NG! scheme_load_file", fn);
      #endif
      return -2;
    } else {
      #ifndef RELEASE
      disp4flow("  load_file", "ok! scheme_load_file", fn);
      #endif
    }
    fclose(fp);
  }
  return 0;
}

//  RETURN
//   0 : OK
//  -1 : NG load_file fopen
//  -2 : NG load_file scheme_load_file
int load_env(scheme *sc, char *env_key, char *name, char *ext) {
  FILE *fp;
  char *env_val, *scm, *dir, *fn;
  int ret;
  env_val = getenv(env_key);
  int len = strlen(env_val);
  int i = 0;
  scm = fullname("", name, ext);
  #ifndef RELEASE
  disp4flow("load_env", "try", scm);
  #endif
  for (int j = 0; j <= len; j++) {
    if (env_val[j] == '\0') {
      dir = strndup(env_val + i, j - i);
      fn  = fullname(dir, name, ext);
      #ifndef RELEASE
      disp4flow("load_env", "try load_file", fn);
      #endif
      if (0 == (ret = load_file(sc, fn))) {
        // load_file OK
	#ifndef RELEASE
        disp4flow("load_env", "ok! load_file", fn);
	#endif
	free(dir); free(fn);
        break;
      }
      // load_file NG
      #ifndef RELEASE
      disp4flow("load_env", "NG! load_file", fn);
      #endif
      free(dir); free(fn);
    } else if (env_val[j] == ':') {
      dir = strndup(env_val + i, j - i);
      fn  = fullname(dir, name, ext);
      #ifndef RELEASE
      disp4flow("load_env", "try load_file", fn);
      #endif
      if (0 == (ret = load_file(sc, fn))) {
        // load_file OK
	#ifndef RELEASE
        disp4flow("load_env", "ok! load_file", fn);
	#endif
	free(dir); free(fn);
	break;
      }
      // load_file NG
      #ifndef RELEASE
      disp4flow("load_env", "NG! load_file", fn);
      #endif
      free(dir); free(fn);
      i = ++j;
    }
  }
  if (ret == 0) {
    disp4flow("load_lib", "ok!", scm);    
  } else {
    disp4flow("load_lib", "NG!", scm);
  }
  free(scm);
  return ret;
}

//  RETURN
//   0 : OK
//  -1 : NG load_file fopen
//  -2 : NG load_file scheme_load_file
int load_lib(scheme *sc, char *name, char *ext) {
  return load_env(sc, LOAD_LIB_ENV, name, ext);
}

//  RETURN
//   0 : OK
//  -1 : NG load_file fopen
//  -2 : NG load_file scheme_load_file
int load_home(scheme *sc, char *name, char *ext) {
  return load_env(sc, "HOME", name, ext);
}

void disp4flow(const char *func, const char *msg1, const char *msg2) {
  printf(DISP4FLOW_FUNC_FORMAT, func);
  printf(DISP4FLOW_MSG1_FORMAT, msg1);
  printf(DISP4FLOW_MSG2_FORMAT, msg2);
}

void set_error(scheme *sc, const char *msg, pointer a) {
  if (a == NULL || a == sc->NIL) {
    sc->args = sc->NIL;
  } else {
    sc->args = _cons(sc, a, sc->args, 1);
  }
  sc->args = _cons(sc, mk_string(sc, msg), sc->args, 1);
  //sc->op = (int)OP_ERR0;
}

//  RETURN
//    0: not yet closing
//    1: closing
int is_closed(char *str) {
  return 1;
}

//  0 : OK
// -1 : NG failed to malloc
int load_string_raw(scheme *sc, char *name) {
  int len = strlen(name);
  printf("read_eval number or symbol name: \"%s\"\n", name);
  char *cmd = (char *)malloc(sizeof(char *) * (len + 6));
  if (cmd == NULL) return -1;
  sprintf(cmd, "(raw %s)", name);
  printf("read_eval number or symbol cmd : \"%s\"\n", cmd);
  scheme_load_string(sc, cmd);
  return 0;
}

//  0 : OK
// -1 : EOF
// -2 : line is empty or line has only space characters
int read_eval(scheme *sc) {
  //char name_buf[READ_BUF_SIZE];
  char read_buf[READ_BUF_SIZE];
  char eval_buf[EVAL_BUF_SIZE];
  char *name;
  int  ofs, len;
  int  first_line = 1;
  while (1) {
    if (first_line) {
      printf("> ");
    } else {
      printf("+ ");
    }
    if (fgets(read_buf, READ_BUF_SIZE, stdin) == NULL) return -1;
    trim_crlf(read_buf, READ_BUF_SIZE);
    ofs = strlens(read_buf);
    if (0 > ofs) return -2;
    if (first_line) {
      //  first line
      strcpy(eval_buf, read_buf);
      //  1st if
      if (read_buf[ofs] == '\'') {
        //  when '
        if (read_buf[ofs + 1] != '(' && read_buf[ofs + 1] != '[') {
          //  Symbol means that line starts-with single-quate + not bracket
	  len  = strlenc(read_buf + ofs + 1, ' ');
          name = strndup(read_buf + ofs + 1, len);
          printf("read_eval #: \"%s\"\n",name);
          sc->value = mk_symbol(sc, name);
          free(name);
          return 0;
        }
	//  go through when '(
      } else if (read_buf[ofs] == '#') {
	//  when #
	if (read_buf[ofs + 1] != '(' && read_buf[ofs + 1] != '[') {
	  //  when #x
          len  = strlenc(read_buf + ofs + 1, ' ');
          name = strndup(read_buf + ofs + 1, len);
	  printf("read_eval #: \"%s\"\n", name);
	  if (strcmp(name, "t") == 0) {
	    sc->value = sc->T;
	  } else if (strcmp(name, "f") == 0) {
	    sc->value = sc->F;
	  } else {
	    sc->value = sc->NIL;
	    sc->retcode = -1;
	    printf("not implemented.\n");
	  }
	  free(name);
          return 0;
	}
	//  go through when #(
      } else if (read_buf[ofs] == '\"') {
	//  when string
        len  = strlenc(read_buf + ofs + 1, '\"');
	name = strndup(read_buf + ofs + 1, len);
	sc->value = mk_string(sc, name);
        printf("read_eval string: \"%s\"\n",name);
	free(name);
	return 0;
      } else {
	//  when number or symbol name
	if (read_buf[ofs] != '(' && read_buf[ofs] != '[') {
          //  Symbol name (reference) means thet line starts-with not bracket
          len  = strlenc(read_buf + ofs, ' ');
          name = strndup(read_buf + ofs, len);
          load_string_raw(sc, name);
          free(name);
          return 0;
        }
	//  go through when (
      }
      //  2nd if
      if (is_closed(eval_buf)) {
	//  begins left bracket && equals between left brackets and right ones 
	break;
      } else {
	//  begins left bracket && equals between left brackets and right ones 
	first_line = 0;
	continue;
      }
    } else {
      //  NOT first line
      strcat(eval_buf, read_buf);
      if (is_closed(eval_buf)) {
	break;
      } else {
	continue;
      }
    }
  }
  scheme_load_string(sc, eval_buf);
  return 0;
}

void print_value(scheme *sc, pointer val, int flag) {
  if (val == sc->NIL) {
    if (flag != 0) printf(" ");
    printf("()");
  } else if (val == sc->T) {
    if (flag != 0) printf(" ");
    printf("#t");
  } else if (val == sc->F) {
    if (flag != 0) printf(" ");
    printf("#f");
  } else if (is_string(val)) {
    if (flag != 0) printf(" ");
    printf("\"%s\"", string_value(val));
  } else if (is_number(val)) {
    if (flag != 0) printf(" ");
    if (is_integer(val)) {
      printf("%ld", ivalue(val));
    } else if (is_real(val)) {
      printf("%g", rvalue(val));
    }
  } else if (is_symbol(val)) {
    if (flag != 0) printf(" ");
    printf("%s", symbol_name(val));
  } else if (is_pair(val)) {
    if (flag != 0) printf(" ");
    if (flag == 0) printf("(");
    print_value(sc, car(val), 0);
    if (is_pair(cdr(val))) {
      print_value(sc, cdr(val), 1);
    } else if (cdr(val) == sc->NIL) {
      printf(")");
    } else {
      printf(" . ");
      print_value(sc, cdr(val), 0);
      printf(")");
    }
  } else if (val == sc->NIL) {
    if (flag != 0) printf(" ");
    printf("()");
  } else {
    if (flag != 0) printf(" ");
    printf("??? ");
  }
}

void print_result(scheme *sc) {
  #ifndef RELEASE
  int flag = ((struct cell*)sc->value)->_flag;
  char *prev = (char *)str_empty;
  printf("retcode = %2d / tracing = %2d / ", sc->retcode, sc->tracing);
  if (sc->value == sc->NIL) {
    printf("value is NIL / type = ");
  } else if (sc->value == sc->T) {
    printf("value is T / type = ");
  } else if (sc->value == sc->F) {
    printf("value is F / type = ");
  } else if (is_number(sc->value)) {
    printf("value = %08X / ", (unsigned int)sc->value);
    printf("type = %s ", str4flag(flag & T_MASKTYPE));
    if (sc->value->_object._number.is_fixnum) {
      prev = "integer";
      printf("%s", prev);
    } else {
      prev = "double";
      printf("%s", prev);
    }
  } else {
    printf("value = %08X / ", (unsigned int)sc->value);
    printf("type = %s ", str4flag(flag & T_MASKTYPE));
  }
  if (is_flag(flag, T_ATOM)) {
    if (prev != str_empty) printf(" ");
    prev = (char *)str_atom;
    printf("%s", str_atom);
  } else {
    prev = (char *)str_empty;
  }
  if (is_flag(flag, T_IMMUTABLE)) {
    if (prev != str_empty) printf(" ");
    prev = (char *)str_immutable;
    printf("%s", str_immutable);
  } else {
    prev = (char *)str_empty;
  }
  if (is_flag(flag, T_SYNTAX)) {
    if (prev != str_empty) printf(" ");
    prev = (char *)str_syntax;
    printf("%s", str_syntax);
  } else {
    prev = (char *)str_empty;
  }
  printf("\n");
  #endif
  print_value(sc, sc->value, 0);
  printf("\n");
}


int maxlen(char **strs) {
  int ret = 0;
  for (int i = 0; strs[i] != NULL; i++) {
    int len = strlen(strs[i]);
    if (ret < len) ret = len;
  }
  return (ret + 1);
}

const char *str_string       = "string";
const char *str_number       = "number";
const char *str_symbol       = "symbol";
const char *str_proc         = "proc";
const char *str_pair         = "pair";
const char *str_closure      = "closure";
const char *str_continuation = "continuation";
const char *str_foreign      = "foreign";
const char *str_character    = "character";
const char *str_port         = "port";
const char *str_vector       = "vector";
const char *str_macro        = "macro";
const char *str_promise      = "promise";
const char *str_environment  = "environment";
const char *str_atom         = "atom";
const char *str_immutable    = "immutable";
const char *str_syntax       = "syntax";
const char *str_empty        = "";

const char *str4flag(int flag) {
  switch (flag & T_MASKTYPE) {
    case T_STRING:       return str_string;
    case T_NUMBER:       return str_number;
    case T_SYMBOL:       return str_symbol;
    case T_PROC:         return str_proc;
    case T_PAIR:         return str_pair;
    case T_CLOSURE:      return str_closure;
    case T_CONTINUATION: return str_continuation;
    case T_FOREIGN:      return str_foreign;
    case T_CHARACTER:    return str_character;
    case T_PORT:         return str_port;
    case T_VECTOR:       return str_vector;
    case T_MACRO:        return str_macro;
    case T_PROMISE:      return str_promise;
    case T_ENVIRONMENT:  return str_environment;
    default:             return str_empty;
  }
}

int is_flag(int flag, int what) {
  if ((flag & what) == what) {
    return 1;
  }
  return 0;
}

void define_list(scheme *sc, char *symbol, char **argv) {
  char *str = (char *)malloc(sizeof(char *) * (maxlen(argv) * 2 + 30));
  sprintf(str, "(define \%s \'())", symbol);
  scheme_load_string(sc, str);
  for (int i = 0; argv[i] != NULL; i++) {
    sprintf(str, "(set! %s (cons \"%s\" %s))", symbol, argv[i], symbol);
    scheme_load_string(sc, str);
  }
  sprintf(str, "(set! %s (reverse %s))", symbol, symbol);
  scheme_load_string(sc, str);
  free(str);
}
