GNATSTYLE=-gnaty3M79SabCdefhiklnprstux
GNATCHECKS=-gnataeEfoU -gnatwae
AFLDIR="$(HOME)/Downloads/newafl/afl-2.52b"
FILES=runit.adb
OBJ=-Dobj -I..

all:
	gnatmake -s $(OBJ) $(GNATCHECKS) $(GNATSTYLE) -O1 $(FILES)

fuzz:
	AFL_CC=egcc gnatmake -s --GCC="$(AFLDIR)/afl-gcc" utf8.adb
