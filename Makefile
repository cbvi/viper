GNATSTYLE=-gnaty3M79SabCdefhiklnprstux
GNATCHECKS=-gnataeEfoU -gnatwae
AFLDIR="$(HOME)/Downloads/newafl/afl-2.52b"
FILES=runit.adb
OBJ=-Dobj -I..
#OPT=-01
OPT=-g

all:
	gnatmake -s $(OBJ) $(GNATCHECKS) $(GNATSTYLE) $(OPT)  $(FILES)

fuzz:
	AFL_CC=egcc gnatmake -s --GCC="$(AFLDIR)/afl-gcc" utf8.adb
