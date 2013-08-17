AC_PREREQ([2.69])

AC_INIT([valacat],
		[0.01],
		[https://github.com/chavaone/valacat/issues])
AC_CONFIG_SRCDIR([src/])
AM_INIT_AUTOMAKE

AM_CONFIG_HEADER([src/config.h])

# Checks for programs.
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MAKE_SET
AM_PROG_VALAC
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

# i18n stuff
IT_PROG_INTLTOOL([0.40.0])

AM_GNU_GETTEXT_VERSION([0.17])
AM_GNU_GETTEXT([external])

GETTEXT_PACKAGE=valacat

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.


AC_CONFIG_FILES([Makefile src/Makefile])
AC_OUTPUT
