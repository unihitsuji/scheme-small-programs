#include <assert.h>

#include "tool.h"

int main (int argc, char **argv) {
  int len;
  //int strlenc(const char *str, char c)
  assert( 2 == strlenc("abcdef", 'c') );
  assert( 6 == strlenc("abcdef", 'z') );
  assert( 0 == strlenc("", 'z')       );
  //int strlens(const char *str)
  assert( -1 == strlens("") );
  assert( -1 == strlens("    ") );
  assert(  1 == strlens(" abc") );
  assert(  3 == strlens("   c") );
  //void trim_crlf(char *buf, int len)
  //char *strrchar(const char *str, int c)
  char *str1 = "12345.abc";
  assert( str1      == strrchar(str1, 'x') );
  assert( str1 +  6 == strrchar(str1, '.') );  // correct 6
  assert( str1 +  9 == strrchar(str1, 'c') );
  //char *fullname(const char *dir, const char *name, const char *ext)
  assert( 0 == strcmp( "123.so"     , fullname(""     , "123", ".so") ) );
  assert( 0 == strcmp( "123.so"     , fullname(NULL   , "123", ".so") ) );
  assert( 0 == strcmp( "123"        , fullname(NULL   , "123", ""   ) ) );
  assert( 0 == strcmp( "123"        , fullname(NULL   , "123", NULL ) ) );
  assert( 0 == strcmp( ""           , fullname(NULL   , NULL , NULL ) ) );
  assert( 0 == strcmp( ""           , fullname(""     , ""   , ""   ) ) );
  assert( 0 == strcmp( "abc/123.so" , fullname("abc"  , "123", ".so") ) );
  assert( 0 == strcmp( "/abc/123.so", fullname("/abc" , "123", ".so") ) );
  assert( 0 == strcmp( "/abc/123.so", fullname("/abc/", "123", ".so") ) );
  return 0;
}
