

uidir = $(pkgdatadir)/
ui_DATA =			\
	po.lang


desktopdir       = $(datadir)/applications
desktop_in_files = gnomecat.desktop.in
desktop_DATA     = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

all-local: $(desktop_DATA)
	@$(DESKTOP_FILE_VALIDATE) $(desktop_DATA)


EXTRA_DIST = \
	po.lang \
	gnome-boxes.desktop.in	\
	$(desktop_in_files)