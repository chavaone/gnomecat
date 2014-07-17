
pluginsdir = $(pkglibdir)/plugins/demochecker/

plugins_LTLIBRARIES = libdemochecker.la

libdemochecker_la_SOURCES = \
	demochecker.vala

libdemochecker_la_CFLAGS = \
	-shared \
	-fPIC \
	$(GNOMECAT_CFLAGS)

libdemochecker_la_LIBADD = \
	$(GNOMECAT_LIBS)

libdemochecker_la_VALAFLAGS = \
	--pkg libpeas-1.0 \
	--pkg gnomecat \
	--vapidir $(top_srcdir)/src
	--library=demochecker

plugins_DATA = demochecker.plugin

EXTRA_DIST = $(plugins_DATA)