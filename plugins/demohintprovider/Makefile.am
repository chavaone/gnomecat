pluginsdir = $(pkglibdir)/plugins/demohintprovider/

plugins_LTLIBRARIES = libdemohintprovider.la

libdemohintprovider_la_SOURCES = \
	demohintprovider.vala

libdemohintprovider_la_CFLAGS = \
	-shared \
	-fPIC \
	$(GNOMECATPLUGINS_CFLAGS)

libdemohintprovider_la_LIBADD = \
	$(GNOMECATPLUGINS_LIBS) \
	$(pkglibdir)/libgnomecat.la

libdemohintprovider_la_VALAFLAGS = \
	$(GNOMECATPLUGINS_VALAFLAGS) \
	--pkg gnomecat \
	--vapidir $(top_srcdir)/src
	--library=demohintprovider

plugins_DATA = demohintprovider.plugin

EXTRA_DIST = $(plugins_DATA)