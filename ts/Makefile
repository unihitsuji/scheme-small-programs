CC      = gcc
AR      = ar
MAKE    = make
CFLAGS  = -I$(HOME)/tinyscheme-1.41 -fPIC
CFLAGS += -DDEBUG
LFLAGS  = -L$(HOME)/tinyscheme-1.41 -ltinyscheme -lncurses

sos       = tsbase.so tsrepl.so tscurses.so
soobjs    = tsbase.o  tsrepl.o  tscurses.o
sosrcs    = tsbase.c  tsrepl.c  tscurses.c
soheaders = tsbase.h  tsrepl.h  tscurses.h

objs      = tool.o ts-tool.o ts-hack.o
srcs      = tool.c ts-tool.c ts-hack.c
headers   = tool.h ts-tool.h ts-hack.h debug.h

all: TAGS $(sos)

TAGS: $(sosrcs) $(soheaders) $(srcs) $(headers)
	ctags -e -R $^

$(sos): %.so: %.o
	$(CC) -shared $(LFLAGS) -o $@ $<

$(soobjs) : %.o : %.c %.h debug.h makefile
	$(CC) $(CFLAGS) -o $@ -c $<

$(objs)   : %.o : %.c %.h debug.h makefile
	$(CC) $(CFLAGS) -o $@ -c $<

ts-tool.o: ts-hack.h debug.h makefile

.PHONY: clean ut install uninstall ls
clean:
	make clean -C ut
	rm -f $(sos) *.o
ut: all
	make ut -C ut

install: $(PREFIX)/lib/tsbase.so $(PREFIX)/lib/tsrepl.so $(PREFIX)/lib/tscurses.so

uninstall:
	rm -f $(PREFIX)/bin/ts-repl
	rm -f $(PREFIX)/lib/tsbase.so
	rm -f $(PREFIX)/lib/tsrepl.so

ls:
	ls $(PREFIX)/bin
	ls $(PREFIX)/lib
	ls $(PREFIX)/share/tinyscheme
	ls $(HOME)/tinyscheme-1.41

$(PREFIX)/lib/tsbase.so: tsbase.so
	cp $< $@

$(PREFIX)/lib/tsrepl.so: tsrepl.so
	cp $< $@

$(PREFIX)/lib/tscurses.so: tscurses.so
	cp $< $@
