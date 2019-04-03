#include <CUnit/CUnit.h>
#include <CUnit/Automated.h>
#include <CUnit/Basic.h>
#include <CUnit/Console.h>
#include <CUnit/CUCurses.h>

#include "tool.h"

void test_strlenc() {
  fprintf(stderr, "test_strlenc start\n");
  //int strlenc(const char *str, char c)
  CU_ASSERT( 2 == strlenc("abcdef", 'c') );
  CU_ASSERT( 6 == strlenc("abcdef", 'z') );
  CU_ASSERT( 0 == strlenc("", 'z')       );
  fprintf(stderr, "test_strlenc end\n");
}

void test_strlens() {
  fprintf(stderr, "test_strlens start\n");
  //int strlens(const char *str)
  CU_ASSERT( -1 == strlens("") );
  CU_ASSERT( -1 == strlens("    ") );
  CU_ASSERT(  1 == strlens(" abc") );
  CU_ASSERT(  3 == strlens("   c") );
  fprintf(stderr, "test_strlens end\n");
}

void test_strrchar() {
  fprintf(stderr, "test_strrchar start\n");
  //char *strrchar(const char *str, int c)
  char *str1 = "12345.abc";
  CU_ASSERT( str1      == strrchar(str1, 'x') );
  CU_ASSERT( str1 +  6 == strrchar(str1, '.') );  // correct 6
  CU_ASSERT( str1 +  9 == strrchar(str1, 'c') );
  fprintf(stderr, "test_strrchar end\n");
}

void test_fullname() {
  fprintf(stderr, "test_fullname start\n");
  //char *fullname(const char *dir, const char *name, const char *ext)
  CU_ASSERT( 0 == strcmp( "123.so"     , fullname(""     , "123", ".so") ) );
  CU_ASSERT( 0 == strcmp( "123.so"     , fullname(NULL   , "123", ".so") ) );
  CU_ASSERT( 0 == strcmp( "123"        , fullname(NULL   , "123", ""   ) ) );
  CU_ASSERT( 0 == strcmp( "123"        , fullname(NULL   , "123", NULL ) ) );
  CU_ASSERT( 0 == strcmp( ""           , fullname(NULL   , NULL , NULL ) ) );
  CU_ASSERT( 0 == strcmp( ""           , fullname(""     , ""   , ""   ) ) );
  CU_ASSERT( 0 == strcmp( "abc/123.so" , fullname("abc"  , "123", ".so") ) );
  CU_ASSERT( 0 == strcmp( "/abc/123.so", fullname("/abc" , "123", ".so") ) );
  CU_ASSERT( 0 == strcmp( "/abc/123.so", fullname("/abc/", "123", ".so") ) );
  fprintf(stderr, "test_fullname end\n");
}

int setup() {
  fprintf(stderr, "setup\n");
  return 0;
}

int teardown() {
  fprintf(stderr, "teardown\n");
  return 0;
}

int main (int argc, char **argv) {
  CU_initialize_registry();
  CU_pSuite suite = CU_add_suite(argv[0], setup, teardown);
  CU_add_test(suite, "test_strlenc" , test_strlenc);
  CU_add_test(suite, "test_strlens" , test_strlens);
  CU_add_test(suite, "test_strrchar", test_strrchar);
  CU_add_test(suite, "test_fullname", test_fullname);
  //void trim_crlf(char *buf, int len)
  CU_set_output_filename(argv[0]);  // default "CUnitAutometed"
  CU_list_tests_to_file();          // xxx-Listing.xml
  //CU_automated_run_tests();         // xxx-Results.xml
  CU_basic_run_tests();
  //CU_console_run_tests();
  //CU_curses_run_tests();
  CU_cleanup_registry();
  return 0;
}
