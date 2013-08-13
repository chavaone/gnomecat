

VALAC = valac
FILES_VALA = filelist.vala  statusbar.vala messagelist.vala tab.vala messageeditor.vala window.vala contextpanel.vala application.vala demofile.vala profile.vala language.vala utils.vala file.vala iterators.vala search.vala
LIBSVALA = --pkg gtk+-3.0 --pkg gdl-3.0 --pkg gee-0.8 --pkg json-glib-1.0 --pkg gtksourceview-3.0 --target-glib=2.38
FILES_C = $(FILES_VALA:.vala=.c) resources.c
FILES_O = $(FILES_C:.c=.o)
CFLAGS = `pkg-config --cflags gtk+-3.0 gdl-3.0 gee-0.8 json-glib-1.0 gmodule-export-2.0 gtksourceview-3.0`
CLIBS = `pkg-config --libs gtk+-3.0 gdl-3.0 gee-0.8 json-glib-1.0 gmodule-export-2.0 gtksourceview-3.0`
PROG_NAME = valacat

all: compile

clean:
	rm -fv *~ *.o *.c $(PROG_NAME)


compileresources:
	glib-compile-resources --generate-source --sourcedir=../data/ --target=resources.c ../data/valacat.gresource.xml

compilevala: $(FILES_VALA)
	$(VALAC) -g -C $(FILES_VALA) $(LIBSVALA) --gresources ../data/valacat.gresource.xml

compilec: compileresources compilevala
	gcc -g  -c $(FILES_C) -Wall $(CFLAGS)

compile: compilec
	gcc -g -o $(PROG_NAME)  $(FILES_O) $(CLIBS)


