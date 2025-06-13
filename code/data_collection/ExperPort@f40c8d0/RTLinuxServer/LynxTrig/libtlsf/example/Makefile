all: test

TLSF_PATH=../src

CFLAGS+=-O2 -I$(TLSF_PATH)

test: test.o $(TLSF_PATH)/tlsf.h
	$(CC) $(CFLAGS) -o test test.o $(TLSF_PATH)/tlsf.o

test.o: test.c $(TLSF_PATH)/tlsf.h

clean:
	$(RM) -rf *.o test *~
