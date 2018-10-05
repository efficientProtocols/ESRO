#!/bin/ksh

. $CURENVBASE/tools/ocp-lib.sh

cd $CURENVBASE/install/OCP/fullDocs

DIST=../dist

mkdir ../dist


case `uname` in
  'Windows_NT')

    #winZipSEProg="D:/Program Files/WinZip Self-Extractor/WZIPSE32.EXE"
    winZipSEProg="D:/WinZipSE21/WZIPSE32.EXE"
    #winZipProg="D:/WinZip95/WINZIP32.EXE"
    winZipProg="D:/WinZip63/WINZIP32.EXE"

    if  [ -x "${winZipSEProg}" ]
    then
      #;
      echo ""
    else
      print -r -- "${winZipSEProg} was not found"
      exit 1
    fi

    if [  -x ${winZipProg} ]
    then
      #;
      echo ""
    else
      print -r -- "${winZipProg} was not found"
      exit 1
    fi


    zipFileName=OCP-docs.zip
    exeZipFileName=OCP-docs.exe
    distName='OCP'



    cat > /tmp/filesToZip << _EOF_
htdocs
docREADME
_EOF_


    "${winZipProg}" -min  -a -r  ${zipFileName}   @/tmp/filesToZip
    ls -l  ${zipFileName}


    cat > MsgFile.txt << _EOF_
You are about to install the documentation suite to accompany Neda Communications, Inc's
${distName}
Product.

_EOF_


    cat > winZipSEInputFile.inp << _EOF_
-y
-win32
-d c:\tmp
-m MsgFile.txt
-c notepad docREADME
_EOF_

    "${winZipSEProg}" ${zipFileName} @winZipSEInputFile.inp

    rm winZipSEInputFile.inp MsgFile.txt /tmp/filesToZip

    rm  $zipFileName

    mv $exeZipFileName $DIST


    print -r -- "Self Extracting Installation File is ready, to try it:"
    print -r -- $DIST/${exeZipFileName}

    ;;
  'SunOS')

    echo Generating tar file ...
    tar cf ../dist/OCP-docs.tar htdocs
    ls -l ../dist/OCP-docs.tar
    echo Generating .gz file ...
    gzip ../dist/OCP-docs.tar
    ls -l ../dist/OCP-docs.tar.gz
    ;;
esac

