
bin_PROGRAMS = valacat

AM_VALAFLAGS =                                              \
    --vapidir $(top_srcdir)/vapi                            \
    --pkg gtk+-3.0                                          \
    --pkg gdl-3.0                                           \
    --pkg gee-0.8                                           \
    --pkg json-glib-1.0                                     \
    --pkg gtksourceview-3.0                                 \
    --pkg gettext-po										\
    --gresources "$(top_srcdir)/data/valacat.gresource.xml" \
    --target-glib=2.38

AM_CPPFLAGS = \
	-DGETTEXT_PACKAGE=\""$(GETTEXT_PACKAGE)"\"  \
	-DGNOMELOCALEDIR=\""$(localedir)"\" \
	-DDATADIR=\""$(pkgdatadir)"\"

VALASOURCES = \
	filelist.vala \
	messagelist.vala \
	tab.vala \
	messageeditor.vala \
	window.vala	\
	contextpanel.vala \
	application.vala \
	demofile.vala \
	profile.vala \
	language.vala \
	file.vala \
	iterators.vala \
	search.vala \
	navigator.vala \
	pofile.vala \
	preferencesdialog.vala \
	hints.vala \
	checker.vala \
	select.vala \
	filter.vala

valacat_SOURCES = \
    $(VALASOURCES)                 \
    valacat.gresource.c	\
    config.vapi

valacat_CFLAGS = \
    -Wall                                                   \
    -g \
    `pkg-config --cflags gtk+-3.0 gdl-3.0 gee-0.8 json-glib-1.0 gmodule-export-2.0 gtksourceview-3.0` \
	`pkg-config --libs gtk+-3.0 gdl-3.0 gee-0.8 json-glib-1.0 gmodule-export-2.0 gtksourceview-3.0` \
	-lgettextpo

CLEANFILES =                                                \
    $(VALASOURCES:.vala=.c)                                 \
    $(BUILT_SOURCES)										\
    valacat.gresource.c						\
    Makefile.in \
    config.h 	\
    config.h.ini \
    config.h.in~ \
    stamp-h1

valacat.gresource.c: $(top_srcdir)/data/valacat.gresource.xml
	glib-compile-resources --generate-source --sourcedir $(top_srcdir)/data/ --target "$@" "$<"

gsettings_SCHEMAS = $(top_srcdir)/data/valacat.gschema.xml
@GSETTINGS_RULES@

gschemas.compiled: $(top_srcdir)/data/valacat.gschema.xml
	$(GLIB_COMPILE_SCHEMAS) $(top_srcdir)/data/
