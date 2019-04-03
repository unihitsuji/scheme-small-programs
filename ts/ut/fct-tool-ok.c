#include "fct.h"

#include "tool.h"

FCT_BGN() {
  FCT_SUITE_BGN(simple) {
    //int strlenc(const char *str, char c)
    FCT_TEST_BGN(chk_eq) {
      fct_chk( 2 == strlenc("abcdef", 'c') );
      fct_chk( 6 == strlenc("abcdef", 'z') );
      fct_chk( 0 == strlenc("", 'z')       );
    } FCT_TEST_END();
    //int strlens(const char *str)
    FCT_TEST_BGN(chk_eq) {
      fct_chk( -1 == strlens("") );
      fct_chk( -1 == strlens("    ") );
      fct_chk(  1 == strlens(" abc") );
      fct_chk(  3 == strlens("   c") );
    } FCT_TEST_END();
    //void trim_crlf(char *buf, int len)
    //char *strrchar(const char *str, int c)
    FCT_TEST_BGN(chk_eq) {
      char *str1 = "12345.abc";
      fct_chk( str1      == strrchar(str1, 'x') );
      fct_chk( str1 +  6 == strrchar(str1, '.') );  // correct 6
      fct_chk( str1 +  9 == strrchar(str1, 'c') );
    } FCT_TEST_END();
    //char *fullname(const char *dir, const char *name, const char *ext)
    FCT_TEST_BGN(strcmp_eq) {
      assert( 0 == strcmp( "123.so"     , fullname(""     , "123", ".so") ) );
      assert( 0 == strcmp( "123.so"     , fullname(NULL   , "123", ".so") ) );
      assert( 0 == strcmp( "123"        , fullname(NULL   , "123", ""   ) ) );
      assert( 0 == strcmp( "123"        , fullname(NULL   , "123", NULL ) ) );
      assert( 0 == strcmp( ""           , fullname(NULL   , NULL , NULL ) ) );
      assert( 0 == strcmp( ""           , fullname(""     , ""   , ""   ) ) );
      assert( 0 == strcmp( "abc/123.so" , fullname("abc"  , "123", ".so") ) );
      assert( 0 == strcmp( "/abc/123.so", fullname("/abc" , "123", ".so") ) );
      assert( 0 == strcmp( "/abc/123.so", fullname("/abc/", "123", ".so") ) );
    } FCT_TEST_END();
  } FCT_SUITE_END();
} FCT_END();
