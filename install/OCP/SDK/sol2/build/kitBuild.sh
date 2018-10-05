#!/bin/ksh
#
# RCS Revision: $Id: kitBuild.sh,v 1.1.1.1 1999/11/15 00:29:06 mohsen Exp $
#

#
# Description:
#     kitBuild.sh
#
#     Makes a gzip'd file of the ESROS SDK components (for Solaris).
#
#     Inputs:
#          - contents of the $CURENVBASE directory.
#     
#     Outputs:
#	   - .tar.gz file
#          NOTYET:
#          - installation on the ftp server and web.
#
#     Dependencies:
#          - pkzip package
#
#
#
# Author: Mark McWiggins
#
#


. ${CURENVBASE}/tools/ocp-lib.sh

print -r -- "Copying SDK distribution to ${CURENVBASE}/install/ESROS/SDK/sol2/dist"

distName='esrosSDK'

cd ${CURENVBASE}/install/ESROS/SDK/sol2

mkdir dist
mkdir dist/include
mkdir dist/include/esros
mkdir dist/include/sysif
mkdir dist/bin
mkdir dist/libc
mkdir dist/data
mkdir dist/examples
mkdir dist/examples/ops_xmpl.cb
mkdir dist/examples/ops_xmpl.cb/invoker
mkdir dist/examples/ops_xmpl.cb/performer
mkdir dist/tools
mkdir dist/results
mkdir dist/results/sol2
mkdir dist/results/bin
mkdir dist/results/libc

CP='cp -p'

DIST=${CURENVBASE}/install/ESROS/SDK/sol2/dist

${CP} ${CURENVBASE}/sourceme.csh ${CURENVBASE}/dotme.bash $DIST

cd $CURENVBASE/tools
${CP}  *  $DIST/tools

${CP} ${CURENVBASE}/tools/pdt-esrosSDK.sh  $DIST/tools/pdt-current.sh

cd ${CURENVBASE}/results

find . -print | cpio -ocB | (cd $DIST/results; cpio -icBdmu)


cd ${CURENVBASE}/src/multiocp

find include.ocp -name '*.h' -exec ${CP} \{\} $DIST/include \;

find sysif.ocp/include.sol2 sysif.ocp/os/sol2 -name '*.h' -exec ${CP} \{\} $DIST/include/sysif \;


cd ..

find esros/include -name '*.h' -exec ${CP} \{\} $DIST/include/esros \;





cd $CURENVBASE/results/sol2
find . -print | grep -v CVS | cpio -ocB | (cd $DIST; cpio -icBdmu)

cd $CURENVBASE/src/esros/ops_xmpl.cb
find .  -print | cpio -ocB | (cd $DIST/examples/ops_xmpl.cb; cpio -icBdmu)

cd $DIST/examples/ops_xmpl.cb
rm -f *.o
cp *.ini $DIST/data

cd $CURENVBASE/src/esros/stress.cb
cp *.ini $DIST/data


${CP} $DIST/../build/sdkREADME $DIST

print -r -- "Making gzipped tar file ..."

cd ${DIST}

tar cf - * | gzip >esrosSDK2.3-sol2.tar.gz
