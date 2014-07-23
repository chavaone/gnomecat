
bin_PROGRAMS = gnomecat

AM_CFLAGS = \
	-g -Wall -pg

AM_CPPFLAGS = \
	-DGETTEXT_PACKAGE=\""$(GETTEXT_PACKAGE)"\"  \
	-DGNOMELOCALEDIR=\""$(localedir)"\" \
	-DDATADIR=\""$(pkgdatadir)"\" \
	-DLIBDIR=\""$(pkglibdir)"\"

AM_VALAFLAGS = \
	--vapidir $(top_srcdir)/vapi \
	$(GNOMECAT_VALAFLAGS) \
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
	pofilerow.vala \
	recentfileswidget.vala \
	pluginmanager.vala \
	pluralform.vala \
	hintswidget.vala \
	api.vala \
	welcomepanel.vala

gnomecat_SOURCES = \
	$(VALASOURCES) \
	gnomecat.gresource.c \
	config.vapi

gnomecat_CFLAGS = \
	$(GNOMECAT_CFLAGS) \
	-lgettextpo

gnomecat_LDADD = \
	$(GNOMECAT_LIBS)

gnomecat_LDFLAGS = -pg

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

BUILT_SOURCES = .libgnomecat.vala.stamp

lib_LTLIBRARIES = libgnomecat.la

libgnomecat_la_VALASOURCES = \
	hints.vala \
	file.vala \
	api.vala \
	select.vala \
	plugins.vala

libgnomecat_la_SOURCES = \
	.libgnomecat.vala.stamp \
	$(libgnomecat_la_VALASOURCES:.vala=.c)

.libgnomecat.vala.stamp: $(libgnomecat_la_VALASOURCES)
	$(VALAC) $(LIBGNOMECAT_VALAFLAGS) -C -H gnomecat.h --library gnomecat $^
	@touch $@

libgnomecat_la_CPPFLAGS = \
	$(LIBGNOMECAT_CFLAGS)

libgnomecat_la_LIBADD = \
	$(LIBGNOMECAT_LIBS)

EXTRA_DIST = $(libgnomecat_la_VALASOURCES)

MAINTAINERCLEANFILES = \
	$(libgnomecat_la_VALASOURCES:.vala=.c)
