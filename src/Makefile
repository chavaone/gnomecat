

VALAC = valac
FILES =	profile.vala statusbar.vala language.vala headerbar.vala messagelist.vala messageeditor.vala tab.vala utils.vala file.vala strings.vala
LIBSVALA = 	--pkg gtk+-3.0 --pkg gdl-3.0 --pkg gee-0.8
RESOURCESFILE = valacatresources.xml

all: compilevala

clean:
	rm -fv *~ *.o $(RESOURCESFILE)

compilevala:
	$(VALAC) $(FILES) $(LIBSVALA) --gresources $(RESOURCESFILE)
