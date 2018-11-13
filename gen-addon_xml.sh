#!/bin/bash
# from chewitt

REPO="/home/pi/repos/LibreELEC.tv/target/addons/9.1"

do_cleanup(){
 rm -rf $REPO/*/*/script.program.driverselect 2>/dev/null
}

do_xml(){
 for PROJECT in $(find $REPO/* -maxdepth 0 -type d); do
   PROJECT=$(basename "$PROJECT")
   for ARCH in $(find $REPO/$PROJECT/* -maxdepth 0 -type d); do
     ARCH=$(basename "$ARCH")
     ARCH_XML='<?xml version="1.0" encoding="UTF-8"?>\n<addons>\n'
     for ADDON in $(find $REPO/$PROJECT/$ARCH/* -maxdepth 0 -type d); do
       ADDON=$(basename "$ADDON")
       for ARCHIVE in $(find $REPO/$PROJECT/$ARCH/$ADDON -type f -name "*.zip" | sort -V); do
         if [ -n "$ARCHIVE" ]; then
           ARCHIVE_XML=$(unzip -p "$ARCHIVE" "$ADDON/addon.xml" | sed '1d' | cat)
           ARCH_XML="$ARCH_XML$ARCHIVE_XML\n"
         fi
       done
     done
     ARCH_XML="$ARCH_XML</addons>"
     echo -e "$ARCH_XML" > $REPO/$PROJECT/$ARCH/addons.xml
     gzip -f $REPO/$PROJECT/$ARCH/addons.xml
     md5sum $REPO/$PROJECT/$ARCH/addons.xml.gz | cut -f1 -d ' ' > $REPO/$PROJECT/$ARCH/addons.xml.gz.md5
     sha256sum $REPO/$PROJECT/$ARCH/addons.xml.gz | cut -f1 -d ' ' > $REPO/$PROJECT/$ARCH/addons.xml.gz.sha256
   done
 done
}

do_cleanup
do_xml

exit
