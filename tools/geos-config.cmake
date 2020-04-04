#!/bin/sh

prefix=@CMAKE_INSTALL_PREFIX@
exec_prefix=@INSTALL_BIN_DIR@
libdir=@INSTALL_LIB_DIR@

usage()
{
    cat <<EOF
Usage: geos-config [OPTIONS]
Options:
     [--prefix]
     [--version]
     [--libs]
     [--clibs]
     [--cclibs]
     [--static-clibs]
     [--static-cclibs]
     [--cflags]
     [--ldflags]
     [--includes]
     [--jtsport]
EOF
    exit $1
}

if test $# -eq 0; then
  usage 1 1>&2
fi

while test $# -gt 0; do
case "$1" in
    -*=*) optarg=`echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'` ;;
    *) optarg= ;;
esac
case $1 in
    --prefix)
      echo @CMAKE_INSTALL_PREFIX@
      ;;
    --version)
      echo @GEOS_VERSION@
      ;;
    --cflags)
      echo -I@INSTALL_INC_DIR@
      ;;
    --libs)
      echo -L@INSTALL_LIB_DIR@ -lgeos-@GEOS_VERSION@
      ;;
    --clibs)
      echo -L@INSTALL_LIB_DIR@ -lgeos_c
      ;;
    --cclibs)
      echo -L@INSTALL_LIB_DIR@ -lgeos
      ;;
    --static-clibs)
      echo -L@INSTALL_LIB_DIR@ -lgeos_c -lgeos -lm
      ;;
    --static-cclibs)
      echo -L@INSTALL_LIB_DIR@ -lgeos -lm
      ;;
    --ldflags)
      echo -L@INSTALL_LIB_DIR@
      ;;
    --includes)
      echo @INSTALL_INC_DIR@
      ;;
    --jtsport)
    echo @JTS_PORT@
      ;;
    *)
      usage 1 1>&2
      ;;
  esac
  shift
done

