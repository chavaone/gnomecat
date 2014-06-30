
bin_PROGRAMS = gnomecat

AM_CFLAGS = \
	-g -Wall

AM_CPPFLAGS = \
	-DGETTEXT_PACKAGE=\""$(GETTEXT_PACKAGE)"\"  \
	-DGNOMELOCALEDIR=\""$(localedir)"\" \
	-DDATADIR=\""$(pkgdatadir)"\"

AM_VALAFLAGS = \
	--vapidir $(top_srcdir)/vapi \
	--pkg gtk+-3.0 \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg gtksourceview-3.0 \
	--pkg gettext-po \
	--gresources "$(top_srcdir)/data/gnomecat.gresource.xml" \
	--target-glib=2.38

VALASOURCES = \
	messagelist.vala \
	messageeditor.vala \
	window.vala \
	application.vala \
	demofile.vala \
	profile.vala \
	language.vala \
	file.vala \
	iterators.vala \
	search.vala \
	navigator.vala \
	pofile.vala \
	hints.vala \
	checker.vala \
	select.vala \
	filter.vala \
	filenavigator.vala \
	toolbar.vala \
	editpanel.vala \
	searchbar.vala \
	utils.vala \
	preferencespanel.vala \
	simpleprofilepanel.vala \
	openedfilespanel.vala \
	panel.vala \
	openfilepanel.vala \
	firstprofilepanel.vala \
	welcomepanel.vala \
	originspopover.vala \
	pofilerow.vala \
	recentfileswidget.vala

gnomecat_SOURCES = \
	$(VALASOURCES) \
	gnomecat.gresource.c \
	config.vapi

gnomecat_CFLAGS = \
	$(GNOMECAT_CFLAGS) \
	-lgettextpo

gnomecat_LDADD = \
	$(GNOMECAT_LIBS)

CLEANFILES = \
	$(VALASOURCES:.vala=.c) \
	$(BUILT_SOURCES) \
	gnomecat.gresource.c \
	Makefile.in \
	config.h \
	config.h.ini \
	config.h.in~

gnomecat.gresource.c: $(top_srcdir)/data/gnomecat.gresource.xml
	glib-compile-resources --generate-source --sourcedir $(top_srcdir)/data/ --target "$@" "$<"

gsettings_SCHEMAS = $(top_srcdir)/data/gnomecat.gschema.xml
@GSETTINGS_RULES@

gschemas.compiled: $(top_srcdir)/data/gnomecat.gschema.xml
	$(GLIB_COMPILE_SCHEMAS) $(top_srcdir)/data/
