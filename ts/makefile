PREFIX = /data/data/com.termux/files/usr
CC     = gcc
INC    = $(HOME)/tinyscheme-1.41
LIB    = $(HOME)/tinyscheme-1.41
CFLAGS = -I$(INC) -fPIC
LFLAGS = -L$(LIB) -ltinyscheme

sos      = tsbase.so tsrepl.so
objs     = tsbase.o  tsrepl.o  tool.o ts-tool.o ts-hack.o ts-repl.o
srcs     = tsbase.c  tsrepl.c  tool.c ts-tool.c ts-hack.c ts-repl.c
headers  = tsbase.h  tsrepl.h  tool.h ts-tool.h ts-hack.h ts-repl.h

all: TAGS $(sos) ts-repl

$(sos): %.so: %.o
	gcc $< -shared $(LFLAGS) -o $@

$(objs): %.o: %.c %.h
	gcc -c $< $(CFLAGS) -o $@

ts-repl.o: ts-tool.h ts-hack.h tsbase.h tool.h
ts-tool.o: ts-hack.h

clean: uninstall
	rm -f $(sos) ts-repl *.o

install: $(PREFIX)/bin/ts-repl $(PREFIX)/lib/tsbase.so $(PREFIX)/lib/tsrepl.so $(PREFIX)/share/tinyscheme/ts-repl.scm

uninstall:
	rm -f $(PREFIX)/bin/ts-repl
	rm -f $(PREFIX)/lib/tsbase.so
	rm -f $(PREFIX)/lib/tsrepl.so
	rm -f $(PREFIX)/share/tinyscheme/ts-repl.scm

$(PREFIX)/lib/tsbase.so: tsbase.so
	cp $< $@

$(PREFIX)/lib/tsrepl.so: tsrepl.so
	cp $< $@

$(PREFIX)/bin/ts-repl: ts-repl
	cp $< $@

$(PREFIX)/share/tinyscheme/ts-repl.scm: ts-repl.scm
	cp $< $@

ls:
	ls $(PREFIX)/bin
	ls $(PREFIX)/lib
	ls $(PREFIX)/share/tinyscheme
	ls $(HOME)/tinyscheme-1.41

ts-repl : $(objs)
	gcc $(objs) $(LFLAGS) -o $@

TAGS: $(srcs) $(headers)
	ctags -e -R $(srcs) $(headers)
