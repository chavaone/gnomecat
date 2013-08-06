

VALAC = valac
FILES_VALA_UI = notebook.vala statusbar.vala headerbar.vala messagelist.vala tab.vala messageeditor.vala window.vala contextpanel.vala
FILES_UI = contextpanel.ui  notebook.ui messageeditortab.ui messagelistrow.ui statusbarprofileslist.ui tab.ui headerbar.ui messageeditortabtiprow.ui messageeditor.ui messagelist.ui statusbar.ui window.ui
FILES_VALA_NON_UI = demofile.vala profile.vala language.vala utils.vala file.vala iterators.vala search.vala
FILES_VALA = $(FILES_VALA_UI) $(FILES_VALA_NON_UI)
LIBSVALA = --pkg gtk+-3.0 --pkg gdl-3.0 --pkg gee-0.8 --pkg json-glib-1.0
UI_RESOURCES = ui_resources.xml
UI_RESOURCES_OUTPUT = ui_resources.c
RESOURCES = ../res/resources.xml
RESOURCES_OUTPUT = resources.c
FILES_C = $(FILES_VALA:.vala=.c) $(UI_RESOURCES_OUTPUT) $(RESOURCES_OUTPUT)
FILES_O = $(FILES_C:.c=.o)
CFLAGS = `pkg-config --cflags gtk+-3.0 gdl-3.0 gee-0.8 json-glib-1.0 gmodule-export-2.0`
CLIBS = `pkg-config --libs gtk+-3.0 gdl-3.0 gee-0.8 json-glib-1.0 gmodule-export-2.0`
PROG_NAME = valacat

all: compile

clean:
	rm -fv *~ *.o *.c $(PROG_NAME)


compileresources: $(RESOURCESFILE) $(FILES_UI)
	glib-compile-resources $(UI_RESOURCES) --target=$(UI_RESOURCES_OUTPUT) --c-name _ui --generate-source
	glib-compile-resources $(RESOURCES) --target=$(RESOURCES_OUTPUT) --sourcedir=../res/ --c-name _json --generate-source

compilevala: $(FILES_VALA)
	$(VALAC) -g -C $(FILES_VALA) $(LIBSVALA) --gresources $(UI_RESOURCES) --gresources $(RESOURCES)

compilec: compileresources compilevala
	gcc -g  -c $(FILES_C) -Wall $(CFLAGS)

compile: compilec
	gcc -g -o $(PROG_NAME)  $(FILES_O) $(CLIBS)


