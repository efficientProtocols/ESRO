#!/bin/ksh
#
# RCS Revision: $Id: kitBuild.sh,v 1.1.1.1 1999/11/15 00:29:06 mohsen Exp $
#

#
# Description:
#     kitBuild.sh
#
#     Makes a self-extracting zip file of the SDK components (for NT).
#
#     Inputs:
#          - contents of the preBuild directory.
#          - target.sh file
#     
#     Outputs:
#          - generated .exe distribution file
#          NOTYET:
#          - installation on the ftp server and web.
#
#     Dependencies:
#          - pkzip package
#          NOTYET:
#          - installshield
#
#
#
# Author: Mark McWiggins
#
#


. ${CURENVBASE}/tools/ocp-lib.sh

print -r -- "Copying SDK distribution to ${CURENVBASE}/install/ESROS/SDK/nt4/dist"

distName='esrosSDK'
winZipSEProg="C:/Program Files/WinZip Self-Extractor/WZIPSE32.EXE"
winZipProg="D:/WinZip95/WINZIP32.EXE"

if  [ -x "${winZipSEProg}" ]
then
  ;
else
  print -r -- "${winZipSEProg} was not found"
  exit 1
fi

if [  -x ${winZipProg} ]
then
  ;
else
  print -r -- "${winZipProg} was not found"
  exit 1
fi


cd ${CURENVBASE}/install/ESROS/SDK/nt4

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
mkdir dist/results/winnt
mkdir dist/results/winnt/x86
mkdir dist/results/winnt/x86/bin
mkdir dist/results/winnt/x86/libc


CP='cp -p'



DIST=${CURENVBASE}/install/ESROS/SDK/nt4/dist


${CP} ${CURENVBASE}/win32setenv.sh $DIST

${CP} ${CURENVBASE}/tools/pdt-esrosSDK.sh  $DIST/tools/pdt-current.sh

cd ${CURENVBASE}/results

find . -print | cpio -ocB | (cd $DIST/results; cpio -icBdmu)


cd ${CURENVBASE}/src/multiocp

find include.ocp -name '*.h' -exec ${CP} \{\} $DIST/include \;

find sysif.ocp/include.nt4 -name '*.h' -exec ${CP} \{\} $DIST/include/sysif \;

cd ..

find esros/include -name '*.h' -exec ${CP} \{\} $DIST/include/esros \;



cd $CURENVBASE/tools
${CP} win32* cpu-x86.sh os-winnt.sh mkp.sh target* ocp-lib.sh checkthebase.pl \
 build* pdt-vorde.sh $DIST/tools


cd $CURENVBASE/results/winnt/x86
find . -print | grep -v CVS | cpio -ocB | (cd $DIST; cpio -icBdmu)
rm $DIST/bin/*.ilk



cd $CURENVBASE/src/esros/ops_xmpl.cb
find .  -print | cpio -ocB | (cd $DIST/examples/ops_xmpl.cb; cpio -icBdmu)

cd $DIST/examples/ops_xmpl.cb
rm *.exe *.ilk *.o
cp *.ini $DIST/data

cd $CURENVBASE/src/esros/stress.cb
cp *.ini $DIST/data


${CP} $DIST/../build/sdkREADME $DIST

print -r -- "Making self-extracting zip file ..."

zipFileName=${distName}.ZIP
exeZipFileName=${distName}.exe

cd ${DIST}

  cat > /tmp/filesToZip << _EOF_
${DIST}\*.*
_EOF_


"${winZipProg}" -min  -a -r  ${zipFileName}   @/tmp/filesToZip
ls -l  ${zipFileName}


  cat > MsgFile.txt << _EOF_
You are about to install Neda Communications, Inc's
${distName}
Product.

_EOF_


cat > winZipSEInputFile.inp << _EOF_
-y
-win32
-d c:\tmp
-m MsgFile.txt
-c notepad sdkREADME
_EOF_

"${winZipSEProg}" ${zipFileName} @winZipSEInputFile.inp

rm winZipSEInputFile.inp MsgFile.txt /tmp/filesToZip

ls -l ${exeZipFileName}

print -r -- "Self Extracting Installation File is ready, to try it:"
print -r -- "cd `DOS_toFrontSlash ${DIST}`"
print -r -- ${exeZipFileName}


