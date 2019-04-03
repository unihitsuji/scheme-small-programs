#include <PCUnit/PCUnit.h>

#include <stdio.h>

#include "debug.h"
#include "tool.h"

int primitive_parse_args(int argc, char **argv, const char *option) {
  int ret = 0;
  for (int i = 0; i < argc; i++)
    if (strcmp(argv[i], option) == 0)
      return 1;
  return ret;
}

void test_strlenc() {
  _DEBUG("test_strlenc start");
  //int strlenc(const char *str, char c)
  PCU_ASSERT( 2 == strlenc("abcdef", 'c') );
  PCU_ASSERT( 6 == strlenc("abcdef", 'z') );
  PCU_ASSERT( 0 == strlenc("", 'z')       );
  _DEBUG("test_strlenc end");
}

void test_strlens() {
  _DEBUG("test_strlens start");
  //int strlens(const char *str)
  PCU_ASSERT_EQUAL( -1, strlens("") );
  PCU_ASSERT_EQUAL( -1, strlens("    ") );
  PCU_ASSERT_EQUAL(  1, strlens(" abc") );
  PCU_ASSERT_EQUAL(  3, strlens("   c") );
  _DEBUG("test_strlens end");
}

void test_strrchar() {
  _DEBUG("test_strrchar start");
  //char *strrchar(const char *str, int c)
  char *str1 = "12345.abc";
  PCU_ASSERT_PTR_EQUAL( str1, strrchar(str1, 'x') );
  PCU_ASSERT_PTR_EQUAL( str1 +  7, strrchar(str1, '.') );  // correct 6
  PCU_ASSERT_PTR_EQUAL( str1 +  9, strrchar(str1, 'c') );
  _DEBUG("test_strrchar end");
}

void test_fullname() {
  _DEBUG("test_fullname start");
  //char *fullname(const char *dir, const char *name, const char *ext)
  PCU_ASSERT_STRING_EQUAL( "123.so"     , fullname(""     , "123", ".so") );
  PCU_ASSERT_STRING_EQUAL( "123.so"     , fullname(NULL   , "123", ".so") );
  PCU_ASSERT_STRING_EQUAL( "123"        , fullname(NULL   , "123", ""   ) );
  PCU_ASSERT_STRING_EQUAL( "123"        , fullname(NULL   , "123", NULL ) );
  PCU_ASSERT_STRING_EQUAL( ""           , fullname(NULL   , NULL , NULL ) );
  PCU_ASSERT_STRING_EQUAL( ""           , fullname(""     , ""   , ""   ) );
  PCU_ASSERT_STRING_EQUAL( "abc/123.so" , fullname("abc"  , "123", ".so") );
  PCU_ASSERT_STRING_EQUAL( "/abc/123.so", fullname("/abc" , "123", ".so") );
  PCU_ASSERT_STRING_EQUAL( "/abc/123.so", fullname("/abc/", "123", ".so") );
  _DEBUG("test_fullname end");
}

int setup() {
  _DEBUG("setup");
  return 0;
}

int teardown() {
  _DEBUG("teardown");
  return 0;
}

int initialize() {
  _DEBUG("initialize");
  return 0;
}

int cleanup() {
  _DEBUG("cleanup");
  return 0;
}

PCU_Suite *ToolTest_suite() {
  static PCU_Test tests[] = {
    { "test_strlenc" , test_strlenc  },
    { "test_strlens" , test_strlens  },
    { "test_strrchar", test_strrchar },
    { "test_fullname", test_fullname }
  };
  static PCU_Suite suite = { "ToolTest_suite", tests, _COUNT(tests), setup, teardown, initialize, cleanup };
  return &suite;
}

int main (int argc, char **argv) {
  int verbose = primitive_parse_args(argc, argv, "--verbose");
  int color   = primitive_parse_args(argc, argv, "--color");
  int console = primitive_parse_args(argc, argv, "--console");
  const PCU_SuiteMethod suites[] = { ToolTest_suite };
  PCU_set_putchar(putchar);
  PCU_set_verbose(verbose);
  if (color) PCU_enable_color();
  if (console) {
    PCU_set_getchar(getchar);
    return PCU_console_run(suites, _COUNT(suites));
  } else {
    return PCU_run(suites, _COUNT(suites));
  }
}
