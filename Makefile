CC=cc

LEX=/usr/bin/lex

COFLAGS=-O2
CWFLAGS=-Wall -Wextra

CFLAGS=$(COFLAGS) $(CWFLAGS) -I.

all: pretty

p2.c: p2.l p2.h
	$(LEX) -o p2.c p2.l

p2.o: p2.c p2.h
	$(CC) $(CFLAGS) -c p2.c

error.o: error.c p2.h
	$(CC) $(CFLAGS) -c error.c

init.o: init.c p2.h
	$(CC) $(CFLAGS) -c init.c

symbol.o: symbol.c p2.h
	$(CC) $(CFLAGS) -c symbol.c

pretty: p2.o error.o init.o symbol.o
	$(CC) $(CFLAGS) -o pretty p2.o error.o init.o symbol.o

clean:	
	rm -f *.o p2.c pretty
