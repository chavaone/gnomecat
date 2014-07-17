pluginsdir = $(pkglibdir)/plugins/demohintprovider/

plugins_LTLIBRARIES = libdemohintprovider.la

libdemohintprovider_la_SOURCES = \
	demohintprovider.vala

libdemohintprovider_la_CFLAGS = \
	-shared \
	-fPIC \
	$(GNOMECAT_CFLAGS)

libdemohintprovider_la_LIBADD = \
	$(GNOMECAT_LIBS)

libdemohintprovider_la_VALAFLAGS = \
	--pkg libpeas-1.0 \
	--pkg gnomecat \
	--vapidir $(top_srcdir)/src
	--library=demohintprovider

plugins_DATA = demohintprovider.plugin

EXTRA_DIST = $(plugins_DATA)