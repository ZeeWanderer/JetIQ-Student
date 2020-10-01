#!/bin/sh -ex
if [ ! "$IS_AZURE" = 'true' -a ! "$ACTION" = 'install'  ] ;
then
   currentNumber=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PRODUCT_SETTINGS_PATH")
   buildNumber=$(git rev-list --count HEAD)
   if [ "$buildNumber" -ne "$currentNumber" ] ; then
      /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$PRODUCT_SETTINGS_PATH"
   fi
fi
