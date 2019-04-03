#ifndef   DEBUG_H
  #define DEBUG_H

  #ifdef DEBUG
    #define _DEBUG(fmt, ...) \
      fprintf(stderr, "_DEBUG %s:%d: " fmt "\n", \
            __FILE__, __LINE__, ##__VA_ARGS__ )
  #else
    #define _DEBUG(fmt, ...) ((void)0)
  #endif

#endif
