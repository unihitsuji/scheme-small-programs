CC      = gcc
AR      = ar
MAKE    = make
CFLAGS  = -I.. -I$(PREFIX)/local/include
CFLAGS += -DDEBUG
LFLAGS  = -L$(PREFIX)/local/lib -lcunit -lncurses -lpcunit

exes    = assert-tool-ng   assert-tool-ok   fct-tool-ng   fct-tool-ok   cunit-tool-ng   cunit-tool-ok   pcunit-tool-ng   pcunit-tool-ok
objs    = assert-tool-ng.o assert-tool-ok.o fct-tool-ng.o fct-tool-ok.o cunit-tool-ng.o cunit-tool-ok.o pcunit-tool-ng.o pcunit-tool-ok.o
srcs    = assert-tool-ng.c assert-tool-ok.c fct-tool-ng.c fct-tool-ok.c cunit-tool-ng.c cunit-tool-ok.c pcunit-tool-ng.c pcunit-tool-ok.c
headers =

.PHONY: all clean ut assert fct cunit pcunit

all: $(exes)

clean:
	rm -f $(exes) *.o

ut: assert fct cunit pcunit

assert: all
	-./assert-tool-ng
	-./assert-tool-ok

fct: all
	-./fct-tool-ng
	-./fct-tool-ok

cunit: all
	-./cunit-tool-ng
	-./cunit-tool-ok

pcunit: all
	-./pcunit-tool-ng --color
	-./pcunit-tool-ok --color

$(exes) : % : %.o ../tool.o
	$(CC) $(LFLAGS) -o $@ $^

$(objs) : %.o : %.c ../tool.h ../debug.h makefile
	$(CC) $(CFLAGS) -o $@ -c $<

../tool.o : ../tool.c ../tool.h
	$(MAKE) -C .. tool.o

#pcunit-tool-ok: pcunit-tool-ok.o ../tool.o
#	$(CC) -L$(PREFIX)/local/lib -lpcunit -o $@ $^  ## for dynamic link
#	$(CC) -o $@ $^ -L$(PREFIX)/local/lib -lpcunit  ## for static  link
