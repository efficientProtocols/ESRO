#!/bin/ksh
#
# RCS Revision: $Id: kitBuild.sh,v 1.3 1999/11/15 07:24:29 mohsen Exp $
#

#
# Description:
#     kitBuild.sh
#
#     Takes the content of preBuild directory and the 
#     product specific file and generates pkzip, tar and 
#     installshield files. Optionally also puts them on the web.
#
#     Inputs:
#          - contents of the preBuild directory.
#          - target.sh file
#     
#     Outputs:
#          - generated pkzip distribution file
#          - tar distribution file
#          - installation on the ftp server and web.
#
#     Dependencies:
#          - pkzip package
#          - installshield
#
#

#
# Author: Mohsen Banan.
#
#

#set -v

. ${CURENVBASE}/tools/ocp-lib.sh


#
# DEFAULTS
#

runOSValidList="SunOS Windows_NT"
#runOSValidList="Windows_NT"

#
# DEFAULTS
#
usage() {
    printf >&2 "Usage: $0 [ -T traceLevel ] [ -u ] [-f flavor] [-s status] [-a arch]\n"
    printf >&2 "Usage: flavor is one of: ${targetProdFlavorValidList}\n"
    printf >&2 "Usage: status is one of: ${targetProdStatusValidList}\n"
    printf >&2 "Usage: arch is one of: ${targetArchTypeValidList}\n"
    exit 1
}

systemName=`uname -n`
devlOsType=`uname -s`


###


#PATH=/usr/sbin:/usr/bin:/sbin

# Get options (defaults immediately below):

badUsage=
traceLevel=

targetConfigFiles=""

TM_trace 9 $*

while getopts p:a:o:f:T:u? c
do
    case $c in
    T)
	case $OPTARG in
	*[!0-9]* )
	    echo "$0: -T requires a numeric option"
 	    badUsage=TRUE
	    ;;
        [0-9]* )
	    traceLevel=$OPTARG
	    ;;
	esac
	;;
    f)
	targetConfigFiles="${targetConfigFiles} ${OPTARG}"
	;;
    p)
	targetDistPasswd="${OPTARG}"
	;;
    a)
        action="${OPTARG}"
	;;
    o)
        optionsList="${optionsList} ${OPTARG}"
	;;
    u | \?)
	badUsage=TRUE
	;;
    esac
done

if [ "${targetConfigFiles}" != "" ]
then
  for i in ${targetConfigFiles}
  do
    if test -f "$i"
    then
      . $i
    elif  test -f "${CURENVBASE}/tools/targets/$i"
    then
      . ${CURENVBASE}/tools/targets/$i
    elif  test -f "${CURENVBASE}/tools/targets/$i.sh"
    then
      . ${CURENVBASE}/tools/targets/$i.sh
    else
      echo "No such flavor or file"
      exit 1
    fi
  done

else
  #. ${CURENVBASE}/tools/target.sh
  . ${CURENVBASE}/tools/newTarget.sh
fi


G_validateOption ${targetProdFlavor} "${targetProdFlavorValidList}"

G_validateOption ${targetProdStatus} "${targetProdStatusValidList}"

G_validateOption ${targetArchType}  "${targetArchTypeValidList}"

G_validateRunOS "${runOSValidList}"

if [ ${badUsage} ]
then
    usage
    exit 1
fi

shift `expr $OPTIND - 1`


# 
HERE=`pwd`

# INPUT 

prodDataBaseDir=${HERE}/../prodData

# OUTPUT

distBaseDir=${HERE}/../dist

distName=${targetDistFileBase}-${targetProdName}-${targetOS}-${targetProdStatus}-${targetProdRevNu}

preDistBaseDir=${HERE}/../dist/${distName}


# BUILD TOOLS 

# WinZip Programs
#winZipSEProg="D:/Program Files/WinZip Self-Extractor/WZIPSE32.EXE"
#winZipProg="D:/Program Files/WinZip/WINZIP32.EXE"


    #winZipSEProg="D:/Program Files/WinZip Self-Extractor/WZIPSE32.EXE"
    winZipSEProg="D:/WinZipSE21/WZIPSE32.EXE"
    #winZipProg="D:/WinZip95/WINZIP32.EXE"
    winZipProg="D:/WinZip63/WINZIP32.EXE"


# Install Shield info should also go here.


# 
# DON'T TOUCH ANYTHING BELOW HERE FOR CONFIGURATION PURPOSES
#

#
# Now that we have all the parameters, get the job done.
#


dirMakeIfNotThere ${distBaseDir}

dirMakeIfNotThere ${preDistBaseDir}



if [ `uname` = 'Windows_NT' ] ; then
  if  [ -x "${winZipSEProg}" ]
  then
    print -r --
  else
    print -r -- "${winZipSEProg} was not found"
    exit 1
  fi

  if [  -x ${winZipProg} ]
  then
    print -r --
  else
    print -r -- "${winZipProg} was not found"
    exit 1
  fi
fi



logActivitySeperator()
{
  print -r -- ""
  print -r -- "-------------------------------------------------------"
}


getRelInfo()
{
  print -r -- "Getting Relevant Information From releaseNotes"

  RELID_extractInfo ${targetReleaseNotesFile}

#    case ${targetProdStatus} in
#     'beta')
#
#       ;;
#     'rel')
#       EH_problem "NOTYET"
#       ;;
#     *)
#       EH_problem "Unknown: ${i}"
#       exit 1
#       ;;
#   esac


LOG_message "   RELID_PROD_NAME=${RELID_PROD_NAME}"
LOG_message "   RELID_REVNUM=${RELID_REVNUM}"
LOG_message "   RELID_Rel_Date=${RELID_REL_DATE}"
LOG_message "   RELID_CVS_Tag=${RELID_CVS_TAG}"
LOG_message "   RELID_BUILD_DATE=${RELID_BUILD_DATE}"
LOG_message "   RELID_BUILD_USER=${RELID_BUILD_USER}"
LOG_message "   RELID_BUILD_HOST=${RELID_BUILD_HOST}"
LOG_message "   RELID_BUILD_DIR=`DOS_toFrontSlash ${CURENVBASE}`"

}


putInDataDir()
{

  specificProductRelNotesBase=${targetProdName}-${targetOS}-${targetProdStatus}

  cp -v ${CURENVBASE}/relnotes/${specificProductRelNotesBase}.tty ${installShieldDataDir}/Neda-${targetProdName}-${targetOS}-ReleaseNotes.tty

}


a_distGenTar()
{

  tarFileName=${distName}.tar

  tarFileFullName=${distBaseDir}/${tarFileName}

  print -r -- "Putting the Distribution Disk in a tar File: ${tarFileFullName}"

  cd ${preDistBaseDir}/.. 

  tar cf ${tarFileFullName} ${distName}

  ls -l ${tarFileFullName}

  echo Generating .gz file ...
  gzip ${tarFileFullName}
  ls -l ${tarFileFullName}.gz

}


a_distGenZip()
{
  print -r -- "Putting the Distribution Self Extracting Zip Files"

  zipFileName=${distName}.ZIP
  exeZipFileName=${distName}.exe

  cd ${distBaseDir}

  cat > filesToZip << _EOF_
${distName}\*.*
_EOF_

  "${winZipProg}" -min  -a -r ${zipFileName}   @filesToZip
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
-c notepad README
_EOF_

  "${winZipSEProg}" ${zipFileName} @winZipSEInputFile.inp

  rm winZipSEInputFile.inp MsgFile.txt filesToZip

  ls -l ${exeZipFileName}

  print -r -- "Self Extarcting Installation File is ready, to try it:"
  print -r -- "cd `DOS_toFrontSlash ${distBaseDir}`"
  print -r -- ${exeZipFileName}
}


#
# From WinCE
# Should become a_distGenZipIShield
#
makeZipFiles()
{
  print -r -- "Putting the Distribution Disk in ZIP Files"

  zipFileName=${targetDistFileBase}-${targetProdStatus}-${RELID_REVNUM}-wce-${targetArchType}.ZIP
  exeZipFileName=${targetDistFileBase}-${targetProdStatus}-${RELID_REVNUM}-wce-${targetArchType}.exe

  cd ${distBaseDir}

  cat > filesToZip << _EOF_
${preDistBaseDir}\*.*
_EOF_

  "${winZipProg}" -min -a -r ${zipFileName} @filesToZip
  ls -l  ${zipFileName}


  cat > MsgFile.txt << _EOF_
Thank you for installing Neda Communications, Inc's  ${RELID_PROD_NAME}  ${RELID_PROD_NAME}-${RELID_REVNUM} (${targetArchType}).

Press the "Setup" botton to proceed.
_EOF_

  cat > winZipSEAbout.txt << _EOF_
Neda Communications, Inc.   
tel: +1-425-644-8026
fax: +1-425-562-9591
E-Mail: info@neda.com
URL: http://www.neda.com/

You are about to install the Two Way Paging Product
${RELID_PROD_NAME}-${RELID_REVNUM}-wce-${targetArchType}
For Windows-CE (${targetArchType}).
_EOF_


cat > winZipSEInputFile.inp << _EOF_
-y
-ishield3
-win32
-d c:\tmp
-t MsgFile.txt
-a winZipSEAbout.txt
_EOF_

  "${winZipSEProg}" ${zipFileName} @winZipSEInputFile.inp

  rm winZipSEInputFile.inp winZipSEAbout.txt MsgFile.txt filesToZip

  ls -l ${exeZipFileName}

  print -r -- "Self Extarcting Installation File is ready, to try it:"
  print -r -- "cd `DOS_toFrontSlash ${distBaseDir}`"
  print -r -- ${exeZipFileName}
}


putItOnTheWeb()
{
  echo "This functioanlity is now accomplished in webInstall.sh"

# if [ "${targetDistPasswd}" = "" ] ; then
#     EH_problem "Must Specify the FTP User Passwd"
#     exit 1
# fi

# ftp -n -i << _EOF_
# open ftp.neda.com
# user ${targetDistUser} ${targetDistPasswd}
# binary
# hash
# cd ~ftp/pub/products/MobileMsgWare/WinCE/${targetProdStatus}
# lcd  `DOS_toFrontSlash ${distBaseDir}`
# put ${exeZipFileName}
# put ${tarFileName}
# pwd
# ls -l
# close
# quit
# _EOF_
}



a_distGenInstallShield()
{
  logActivitySeperator
  compileSetup

  logActivitySeperator
  putInDataDir

  logActivitySeperator
  compressDataDir

  logActivitySeperator
  splitData

  logActivitySeperator
  makeDistDisks
}


a_all()
{
# Now do it all

logActivitySeperator
cleanAll

#getIshield3Essentails

logActivitySeperator
getRelInfo

case ${targetDistMethod} in
  'net-all')
    logActivitySeperator
    makeTarFiles

    logActivitySeperator
    makeZipFiles

    #logActivitySeperator
    #putItOnTheWeb
    ;;
  'disk'|'local'|'private')
    ;;
  *)
    EH_problem "Unknown: ${i}"
    exit 1
    ;;
esac
}

a_notyet()
{
  # $1 is the module name
  print -r -- "action $0 (${action}) not implemented yet"
}


a_preDistBuild()
{
  # Make sure preDist is clean
  echo Cleaning ${preDistBaseDir}
  rm -r -f ${preDistBaseDir}

  dirMakeIfNotThere ${preDistBaseDir}

  echo Putting base distribution files in ${preDistBaseDir}
  # Put All The base files in place

  a_baseFilesListMake | \
  a_baseFilesTake | \
  a_baseFilesPut

  # Add to them all the product specific files
  
  #
  ttyTargetReleaseNotesSpecificFile=${targetReleaseNotesSpecificFile%%\.*}.tty


  if [ -r ${ttyTargetReleaseNotesSpecificFile} ]
  then
    cp ${ttyTargetReleaseNotesSpecificFile} ${prodDataBaseDir}/relnotes
  else
    print -r -- "${ttyTargetReleaseNotesSpecificFile} was not found"
    #exit 1
  fi

  # Now Add To It Product Specific Data

  cd ${prodDataBaseDir}
  find . -print | egrep -v '/CVS'|  cpio -ocB | (cd ${preDistBaseDir}; cpio -icBdmu)

}


a_baseFilesListMake()
{
  cd ${CURENVBASE}

  find . -print | \
   egrep -v '/inv10|/inv20|/inv30|/inv40|/inv50|/inv60|/inv70|/inv80' | \
   egrep -v '/perf10|/perf20|/perf30|/perf40|/perf50|/perf60|/perf70|/perf80' | \
   egrep -v '/include.ae|/a-engine' | \
   egrep -v '/install|README' 

   #egrep -v '/CVS' | /relnotes

}

a_baseFilesTake()
{
  cd ${CURENVBASE}
  
  cpio -ocB
}

a_baseFilesPut()
{
  cd ${preDistBaseDir}
  
  cpio -icdBm
}



case ${action} in
  'clean') 
    a_notyet
    ;;

  'all') 
    # Let the traget file information 
    # tell us everything
    a_notyet
    ;;


  # dist installation (distPut) actions

  'distPutTar')
    a_distPutTar
    ;;

  'distPutPKZip')
    a_distPutPKZip
    ;;

  # dist generation (distGen) actions

  'distGenInstallShield') 
    a_distGenInstallShield
    ;;

  # Zip Files For Install Shield Generation
  'distGenZipIShield') 
    a_distGenZipIShield
    ;;
  
  # Simple Zip Distribution
  'distGenZip') 
    a_distGenZip
    ;;

 'distGenTar') 
    a_distGenTar
    ;;

# PreDistActions
  'preDistBuild') 
    a_preDistBuild
    ;;
  'baseFilesListMake') 
    a_baseFilesListMake
    ;;
  'baseFilesTake') 
    a_baseFilesTake
    ;;
  'baseFilesPut') 
    a_baseFilesPut
    ;;


  *)
    EH_problem "Unknown action: ${action}"
    exit 1
    ;;
esac
