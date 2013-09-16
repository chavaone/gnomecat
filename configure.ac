AC_PREREQ([2.69])

AC_INIT([valacat],
		[0.01],
		[https://github.com/chavaone/valacat/issues])
AC_CONFIG_SRCDIR([src/application.vala])
AM_INIT_AUTOMAKE

AM_CONFIG_HEADER([src/config.h])


# i18n stuff
IT_PROG_INTLTOOL([0.40.0])

AM_GNU_GETTEXT_VERSION([0.17])
AM_GNU_GETTEXT([external])

GETTEXT_PACKAGE=valacat

#GSettings
GLIB_GSETTINGS

# Checks for programs.
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AM_PROG_VALAC
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

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

AC_OUTPUT
