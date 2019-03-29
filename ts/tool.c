#include "tool.h"

//  DESCRIPTION
//    returns length of string that terminated \0 or char c
//    'c' of the tail means character
//  RETURN
//    0 <=
int strlenc(const char *str, char c) {
  int i;
  for (i = 0; str[i] != '\0' && str[i] != c; i++);
  return i;
}

//  DESCRIPTION
//    returns space length of string that terminated \0
//    's' of the tail means space
//  RETURN
//    0 <= : OK  length of space character, or
//               offset of appearing (not space) character
//    0 >  : NG  not found (not space) character
int strlens(const char *str) {
  int i;
  for (i = 0; str[i] != '\0'; i++) {
    if (str[i] != ' ' && str[i] != '\t') return i;
  }
  return -1;
}

void trim_crlf(char *buf, int len) {
  int i;
  for (i = 0; i < len && buf[i] != '\0'; i++);
  if (i > 0 && buf[i - 2] == '\r') buf[i - 2] = '\0'; // CR for CR + LF
  if (i > 0 && buf[i - 1] == '\n') buf[i - 1] = '\0'; // LF for CR + LF
  if (i > 0 && buf[i - 1] == '\r') buf[i - 1] = '\0'; // CR
}

//  NOTE:
//    different from strrchr.
//     1 when found character 'c'
//         strrchr  returns a pointer to      position of 'c'
//         strrchar returns a pointer to next position of 'c'
//     2 when not found character 'c' in str,
//         strrchr  returns NULL,
//         strrchar returns str.
char *strrchar(const char *str, int c) {
  int i;
  for (i = strlen(str); 0 <= i && str[i] != c; i--);
  return (char *)(str + i + 1);
}

char *fullname(const char *dir, const char *name, const char *ext) {
  char *ret;
  int len = 0;
  if (dir  != NULL) len += strlen(dir);
  if (name != NULL) len += strlen(name);
  if (ext  != NULL) len += strlen(ext);
  ret = (char *)malloc(sizeof(char *) * (len + 2));
  if (ret == NULL) return NULL;
  if (dir == NULL || strcmp(dir, "") == 0) {
    ret[0] = '\0';
  } else {
    strcpy(ret, dir);
    strcat(ret, "/");
  }
  if (strcmp(dir, "") != 0) strcat(ret, "/");
  if (name != NULL) strcat(ret, name);
  if (ext  != NULL) strcat(ret, ext);
  return ret;
}
