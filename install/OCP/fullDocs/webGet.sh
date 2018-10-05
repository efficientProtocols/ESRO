#!/bin/ksh

CURENVBASE=`pwd`

. /usr/curenv/bin/ocp-lib.sh 
. /usr/curenv/bin/neda-lib.sh

if NEDA_isInDevenv 
then
  #echo We are in devenv
  nedaPublic=/usr/devenv/doc/nedaPublic
  nedaProducts=/usr/devenv/doc/nedaProducts
  webCommonBase=/usr/devenv/webs/commonBase
elif NEDA_isInCurenv
then
  #echo We are in curenv
  nedaPublic=/usr/curenv/doc/nedaPublic
  nedaProducts=/usr/curenv/doc/nedaProducts
  webCommonBase=/usr/curenv/webs/commonBase
else
  echo We are neither in curenv nor in devenv
  echo defaults set to ...
  nedaPublic=/usr/devenv/doc/nedaPublic
  nedaProducts=/usr/devenv/doc/nedaProducts
  esroBaseSrc=/usr/devenv/doc/esroPublic
  webCommonBase=/usr/devenv/webs/commonBase
fi

echo CURENVBASE set to: ${CURENVBASE}

echo ------ List Of Source Directories ------
echo nedaPublic set to ${nedaPublic}
echo nedaProducts set to: ${nedaProducts}
echo webCommonBase set to: ${webCommonBase}

#------------------------index--------------------------
dstDir=${CURENVBASE}/htdocs
# /usr/devenv/doc/nedaProducts/OCP/webs/ocpTechnology/index/main

srcDir=${nedaProducts}/OCP/webs/ocpTechnology/index/main

neda_ttyTexWebCopy ${srcDir} ${dstDir}

PN_fileVerify ${dstDir}/index.html

#--------------------webs/ocpTechnology/onlineDocSystem------------------------------
dstDir=${CURENVBASE}/htdocs/onlineDocSystem
# /usr/devenv/doc/nedaProducts/OCP/webs/ocpTechnology/onlineDocSystem
srcDir=${nedaProducts}/OCP/webs/ocpTechnology/onlineDocSystem/main

neda_ttyTexWebCopy ${srcDir} ${dstDir}

PN_fileVerify ${dstDir}/index.html

#--------------------webs/ocpTechnology/prodRelNotes------------------------------
dstDir=${CURENVBASE}/htdocs/prodRelNotes
# /usr/devenv/doc/nedaProducts/OCP/webs/ocpTechnology/prodRelNotes/main
srcDir=${nedaProducts}/OCP/webs/ocpTechnology/prodRelNotes/main

neda_ttyTexWebCopy ${srcDir} ${dstDir}

PN_fileVerify ${dstDir}/index.html

#--------------------webs/esroTechnology/prodDataSheet------------------------------
dstDir=${CURENVBASE}/htdocs/prodDataSheet
# /usr/devenv/doc/nedaProducts/OCP/webs/ocpTechnology/prodDataSheet/main
srcDir=${nedaProducts}/OCP/webs/ocpTechnology/prodDataSheet/main

neda_ttyTexWebCopy ${srcDir} ${dstDir}

PN_fileVerify ${dstDir}/index.html

#
# Get The Data Sheet
#
# /usr/devenv/doc/nedaProducts/OCP/dataSheet/
srcDir=${nedaProducts}/OCP/dataSheet

cp ${srcDir}/ocp.fm5.pdf ${dstDir}/ocp.pdf
cp ${srcDir}/ocp.fm5.ps ${dstDir}/ocp.ps

#--------------------webs/esroTechnology/licenses------------------------------
dstDir=${CURENVBASE}/htdocs/licenses
# /usr/devenv/doc/nedaProducts/OCP/webs/ocpTechnology/licenses/main
srcDir=${nedaProducts}/OCP/webs/ocpTechnology/licenses/main

neda_ttyTexWebCopy ${srcDir} ${dstDir}

PN_fileVerify ${dstDir}/index.html


#------------------------icons--------------------------
dstDir=${CURENVBASE}/htdocs/latex2html-98.1p1/icons.gif
# /usr/devenv/webs/commonBase/latex2html-98.1p1/icons.gif
srcDir=${webCommonBase}/latex2html-98.1p1/icons.gif

mkdir -p ${dstDir}

cp ${srcDir}/* ${dstDir}

#------------------------logo--------------------------
dstDir=${CURENVBASE}/htdocs/pics
# /usr/devenv/webs/commonBase/pics/
srcDir=${webCommonBase}/pics

mkdir -p ${dstDir}

cp ${srcDir}/*.gif ${dstDir}

PN_fileVerify ${dstDir}/*


#-----------------------docs/openCPlatform---------------------------
dstDir=${CURENVBASE}/htdocs/docs/openCPlatform
# /usr/devenv/doc/nedaPublic/software/openCPlatform-tty/
srcDir=${nedaPublic}/software/openCPlatform-tty

mkdir -p ${dstDir} ${dstDir}/one ${dstDir}/split  ${dstDir}/figures

cp ${srcDir}/main/* ${dstDir}/split
cp ${srcDir}/one-main/* ${dstDir}/one
cp ${srcDir}/main.ps ${dstDir}
cp ${srcDir}/main.pdf ${dstDir}
cp ${srcDir}/main.tty ${dstDir}
cp ${srcDir}/*.txt ${dstDir}
cp ${srcDir}/figures/*.gif ${dstDir}/figures

PN_fileVerify ${dstDir}/main.pdf
PN_fileVerify ${dstDir}/main.ps
PN_fileVerify ${dstDir}/main.tty

