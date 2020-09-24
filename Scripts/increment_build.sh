#!/bin/sh -ex
if [ ! ${IS_AZURE} ]
then
   currentNumber=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PRODUCT_SETTINGS_PATH")
   buildNumber=$(git rev-list --count HEAD)
   if [ "$buildNumber" -ne "$currentNumber" ] ; then
      /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$PRODUCT_SETTINGS_PATH"
   fi
fi
