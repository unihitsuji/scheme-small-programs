#include "tool.h"

int main (int argc, char **argv) {
  int len;
  //int strlenc(const char *str, char c)
  len = strlenc("abcdef", 'c');
  fprintf(stderr, "%d expected %d\n", len, 2);
  len = strlenc("abcdef", 'z');
  fprintf(stderr, "%d expected %d\n", len, 6);
  //int strlens(const char *str)
  //void trim_crlf(char *buf, int len)
  //char *strrchar(const char *str, int c)
  //char *fullname(const char *dir, const char *name, const char *ext)
  return 0;
}
