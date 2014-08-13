
pluginsdir = $(pkglibdir)/plugins/demochecker/

plugins_LTLIBRARIES = libdemochecker.la

libdemochecker_la_SOURCES = \
	demochecker.vala

libdemochecker_la_CFLAGS = \
	-shared \
	-fPIC \
	$(GNOMECATPLUGINS_CFLAGS)

libdemochecker_la_LIBADD = \
	$(GNOMECATPLUGINS_LIBS) \
	$(pkglibdir)/libgnomecat.la

libdemochecker_la_VALAFLAGS = \
	$(GNOMECATPLUGINS_VALAFLAGS) \
	--pkg gnomecat \
	--vapidir $(top_srcdir)/src
	--library=demochecker

plugins_DATA = demochecker.plugin

EXTRA_DIST = $(plugins_DATA)