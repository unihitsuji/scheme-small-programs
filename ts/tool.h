#ifndef   TOOL_H
  #define TOOL_H
  #include <string.h>
  #include <stdlib.h>
  extern       int     strlenc(const char *str, char c);
  extern       int     strlens(const char *str);
  extern       void    trim_crlf(char *buf, int len);
  extern       char   *strrchar(const char *str, int c);
  extern       char   *fullname(const char *dir, const char *name, const char *ext);
#endif
