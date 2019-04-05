include Makefile.inc

CFLAGS  = -I$(HOME)/tinyscheme-1.41 -fPIC
CFLAGS += -DDEBUG
LFLAGS  = -L$(HOME)/tinyscheme-1.41 -ltinyscheme -lncurses

deps      = debug.h Makefile.inc Makefile

sos       = tsbase.so tsrepl.so tscurses.so
soobjs    = tsbase.o  tsrepl.o  tscurses.o
sosrcs    = tsbase.c  tsrepl.c  tscurses.c
soheaders = tsbase.h  tsrepl.h  tscurses.h

objs      = tool.o ts-tool.o ts-hack.o
srcs      = tool.c ts-tool.c ts-hack.c
headers   = tool.h ts-tool.h ts-hack.h debug.h

all: TAGS $(sos)

TAGS: $(sosrcs) $(soheaders) $(srcs) $(headers)
	$(CTAGS) -e -R $^

$(sos): %.so: %.o
	$(CC) -shared $(LFLAGS) -o $@ $<

$(soobjs) : %.o : %.c %.h $(deps)
	$(CC) $(CFLAGS) -o $@ -c $<

$(objs)   : %.o : %.c %.h $(deps)
	$(CC) $(CFLAGS) -o $@ -c $<

ts-tool.o: ts-hack.h $(deps)

.PHONY: clean ut install uninstall ls
clean:
	$(MAKE) clean -C ut
	-$(RM) -f $(sos) *.o
ut: all
	$(MAKE) ut -C ut

install: $(PREFIX)/lib/tsbase.so $(PREFIX)/lib/tsrepl.so $(PREFIX)/lib/tscurses.so

uninstall:
	-$(RM) -f $(PREFIX)/bin/ts-repl
	-$(RM) -f $(PREFIX)/lib/tsbase.so
	-$(RM) -f $(PREFIX)/lib/tsrepl.so

ls:
	-$(LS) $(PREFIX)/bin
	-$(LS) $(PREFIX)/lib
	-$(LS) $(PREFIX)/share/tinyscheme
	-$(LS) $(HOME)/tinyscheme-1.41

$(PREFIX)/lib/tsbase.so: tsbase.so
	$(CP) $< $@

$(PREFIX)/lib/tsrepl.so: tsrepl.so
	$(CP) $< $@

$(PREFIX)/lib/tscurses.so: tscurses.so
	$(CP) $< $@
