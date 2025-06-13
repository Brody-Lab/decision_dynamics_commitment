
SRCDIR = LynxTWO
MOD = LynxTWO-RT.o

all:
	@cd $(SRCDIR) && make -f Makefile ;  [ -f $(MOD) ] && cp -f $(MOD) ..
	@cd ..

clean:
	rm -f *.o *~ Makefile.bak *\#
	@cd $(SRCDIR) && make -f Makefile clean
	@cd ..
