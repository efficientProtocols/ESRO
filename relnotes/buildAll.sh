#!/bin/ksh
#
# RCS Revision: $Id: buildAll.sh,v 1.4 1999/11/15 00:24:29 mohsen Exp $
#

#
# Description:
#       Sample File for a do-some-stuff script
#
#  Example:
#
#       For WIN95/WINNT
#            ./doSomeStuff.sh -f os-winnt.sh -f win32.sh
#
#       For WINCE
#           doSomeStuff.sh -f os-wince -f cpu-mips  -f win32
#
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

while getopts T:u? c
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
  . ${CURENVBASE}/tools/target.sh
fi

targetConfigCmd=""
for i in ${targetConfigFiles}
do
  targetConfigCmd="${targetConfigCmd} -f ${i}"
done


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
# Now that we have all the parameters, get the job done.
#



getRelInfo()
{
  #print -r -- "Getting Relevant Information From releaseNotes"

  RELID_extractInfo ${targetReleaseNotesFile}
  . ${CURENVBASE}/tools/target.sh
  
  #${CURENVBASE}/tools/targetVarsExpand.sh < ${CURENVBASE}/tools/targetInSample.txt
}

getRelInfo

TM_trace 9 "before"


#
# 
# First Build the product announcement and 
# the product README File
#
familyProductRelNotesFile=`FN_nonDirsPart ${targetReleaseNotesFamilyFile}`
#specificProductRelNotesFile=${targetProdName}-${targetOS}-${targetProdStatus}.ttytex
specificProductRelNotesFile=`FN_nonDirsPart ${targetReleaseNotesSpecificFile}`

echo Building the Family-Product Release Notes: ${familyProductRelNotesFile}
texBuild.sh -a tty ${familyProductRelNotesFile}
texBuild.sh -a ps ${familyProductRelNotesFile}
texBuild.sh -a pdf ${familyProductRelNotesFile}

echo Building the Specific-Product Release Notes: ${specificProductRelNotesFile}
texBuild.sh -a tty ${specificProductRelNotesFile}
texBuild.sh -a ps ${specificProductRelNotesFile}
texBuild.sh -a pdf ${specificProductRelNotesFile}

#
#
texBuild.sh -a clean ${familyProductRelNotesFile} ${specificProductRelNotesFile}
#texBuild.sh -a realclean ETWP-wce-beta.ttytex ETWP-wce-gold.ttytex baseua-mul-beta.ttytex baseua-mul-gold.ttytex

