include /usr/rtlinux/rtl.mk
CFLAGS:= $(CFLAGS) -D_IA32_

all: tlsf.o

tlsf.o: tlsf.h tlsf.c arch_dep.h

clean:
	$(RM) -f *.o *~
