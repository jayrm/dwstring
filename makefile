FBC := fbc.exe
FBCFLAGS := -w pedantic

ifdef DEBUG
FBCFLAGS += -g -exx
else
# FBCFLAGS += -s gui
endif

VPATH = .

##########################

all: tests.exe

libdwstring.a: dwstring.bas dwstring.bi
	$(FBC) -lib $(FBCFLAGS) $<

tests.exe: tests.bas libdwstring.a
	$(FBC) $(FBCFLAGS) $< -x $@

.PHONY : clean
clean:
	-rm -f tests.exe libdwstring.a
