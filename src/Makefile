

VALAC = valac
FILES_VALA_UI = statusbar.vala headerbar.vala messagelist.vala tab.vala messageeditor.vala window.vala contextpanel.vala
FILES_UI = contextpanel.ui  hintpanel.ui messageeditortab.ui messagelistrow.ui statusbarprofileslist.ui tab.ui headerbar.ui messageeditortabtiprow.ui messageeditor.ui messagelist.ui statusbar.ui window.ui
FILES_VALA_NON_UI = demofile.vala profile.vala language.vala utils.vala file.vala strings.vala
FILES_VALA = $(FILES_VALA_UI) $(FILES_VALA_NON_UI)
LIBSVALA = --pkg gtk+-3.0 --pkg gdl-3.0 --pkg gee-0.8 --pkg json-glib-1.0
RESOURCESFILE = valacatresources.xml
FILES_C = $(FILES_VALA:.vala=.c) $(RESOURCESFILE:.xml=.c)
FILES_O = $(FILES_C:.c=.o)
CFLAGS = `pkg-config --cflags gtk+-3.0 gdl-3.0 gee-0.8 json-glib-1.0 gmodule-export-2.0`
CLIBS = `pkg-config --libs gtk+-3.0 gdl-3.0 gee-0.8 json-glib-1.0 gmodule-export-2.0`

all: compile

clean:
	rm -fv *~ *.o *.c


compileresources: $(RESOURCESFILE) $(FILES_UI)
	glib-compile-resources $(RESOURCESFILE) --target=$(RESOURCESFILE:.xml=.c) --sourcedir=$(srcdir) --c-name _my --generate-source

compilevala: $(FILES_VALA)
	$(VALAC) -g -C $(FILES_VALA) $(LIBSVALA) --gresources $(RESOURCESFILE)

compilec: compileresources compilevala
	gcc -g  -c $(FILES_C) -Wall $(CFLAGS)

compile: compilec
	gcc -g  $(FILES_O) $(CLIBS)


