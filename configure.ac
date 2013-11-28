AC_PREREQ([2.69])

AC_INIT([gnomecat],
		[0.01],
		[https://github.com/chavaone/valacat/issues])
AC_CONFIG_SRCDIR([src/application.vala])
AM_INIT_AUTOMAKE

AM_CONFIG_HEADER([src/config.h])


# i18n stuff
IT_PROG_INTLTOOL([0.40.0])

AM_GNU_GETTEXT_VERSION([0.17])
AM_GNU_GETTEXT([external])
GETTEXT_PACKAGE=AC_PACKAGE_NAME
AC_SUBST([GETTEXT_PACKAGE])
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE",[The name of the gettext domain])


#GSettings
GLIB_GSETTINGS

# Checks for programs.
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AM_PROG_VALAC
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

PKG_PROG_PKG_CONFIG([0.22])

PKG_CHECK_MODULES(GNOMECAT, [
    glib-2.0 >= 2.38
    gtk+-3.0 >= 3.9.16
    gtksourceview-3.0 >= 3.0.0
    gee-0.8
    json-glib-1.0
])

# Checks for libraries
AC_CHECK_LIB([gettextpo], [po_message_msgid_plural])

# Checks for header files.
AC_CHECK_HEADERS([float.h stdlib.h string.h])

# Checks for library functions.
AC_CHECK_FUNCS([atexit memchr memset strstr])

AC_CONFIG_FILES([
Makefile
src/Makefile
po/Makefile.in
data/Makefile])

echo "
    gnomecat ${VERSION}

    prefix: ${prefix}
    Vala compiler: ${VALAC}
    C compiler: ${CC}

    Now type 'make' to build ${PACKAGE}
"

AC_OUTPUT
