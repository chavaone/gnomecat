
bin_PROGRAMS = valacat

AM_VALAFLAGS =                                              \
    --vapidir $(top_srcdir)/vapi                            \
    --pkg gtk+-3.0                                          \
    --pkg gdl-3.0                                           \
    --pkg gee-0.8                                           \
    --pkg json-glib-1.0                                     \
    --pkg gtksourceview-3.0                                 \
    --gresources "$(top_srcdir)/data/valacat.gresource.xml" \
    --target-glib=2.38

VALASOURCES = filelist.vala statusbar.vala messagelist.vala tab.vala messageeditor.vala window.vala contextpanel.vala application.vala demofile.vala profile.vala language.vala utils.vala file.vala iterators.vala search.vala

valacat_SOURCES = \
    $(VALASOURCES)                                          \
    config.vapi                                             \
    valacat.gresource.c

valacat_CFLAGS = \
    -Wall                                                   \
    -g \
    `pkg-config --cflags gtk+-3.0 gdl-3.0 gee-0.8 json-glib-1.0 gmodule-export-2.0 gtksourceview-3.0` \
	`pkg-config --libs gtk+-3.0 gdl-3.0 gee-0.8 json-glib-1.0 gmodule-export-2.0 gtksourceview-3.0`

valacat.gresource.c: $(top_srcdir)/data/valacat.gresource.xml
	glib-compile-resources --generate-source --sourcedir $(top_srcdir)/data/ --target "$@" "$<"

CLEANFILES =                                                \
    $(VALASOURCES:.vala=.c)                                 \
    $(BUILT_SOURCES)
