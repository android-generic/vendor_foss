#!/system/bin/sh


ARCH=$(getprop ro.bionic.arch)
APK_PATH=/system/etc/preinstall
POST_INST=/data/vendor/post_inst_complete
USER_APPS=$APK_PATH/*
BUILD_DATETIME=$(getprop ro.build.date.utc)
POST_INST_NUM=$(cat $POST_INST)

install_apk() {
   LOG_FILE="/data/misc/fossapks/install_apk.log"
   mkdir -p "$(dirname "$LOG_FILE")"

   echo "Installing $1" >> "$LOG_FILE"

   APK_FILENAME=""
   if [ -f "$APK_PATH/$1_$ARCH" ]; then
      APK_FILENAME="$APK_PATH/$1_$ARCH"
   elif [ -f "$APK_PATH/$1_all" ]; then
      APK_FILENAME="$APK_PATH/$1_all"
   elif [ -f "$APK_PATH/$1" ]; then
	  APK_FILENAME="$APK_PATH/$1"
   else
      echo "Error: APK file not found for $1" >> "$LOG_FILE"
      return
   fi

   pm install -g "$APK_FILENAME" >> "$LOG_FILE"

   # Get the package name from the APK file
   PACKAGE_NAME=$(unzip -p "$APK_FILENAME" AndroidManifest.xml | grep -oE 'package=\"[^\"]+' | cut -d '"' -f 2)
   echo "Package name for $1: $PACKAGE_NAME" >> "$LOG_FILE"
   if [ -z "$PACKAGE_NAME" ]; then
      echo "Error: Unable to retrieve package name for $1" >> "$LOG_FILE"
      return
   fi

   # Get the permissions used by the APK
   PERMISSIONS=$(dumpsys package $PACKAGE_NAME | grep "permissions:")
   echo "Permissions used by $1:" >> "$LOG_FILE"
   echo "$PERMISSIONS" >> "$LOG_FILE"

   # Grant each permission if needed
   for PERMISSION in $PERMISSIONS; do
      GRANTED_PERMISSIONS=$(echo "$PERMISSION" | cut -d ':' -f 2 | tr -d ' ')
      if ! pm permissions $PACKAGE_NAME | grep -q "$PERMITTED_PERMISSIONS"; then
         echo "Granting permission $PERMISSION" >> "$LOG_FILE"
         if pm grant $PACKAGE_NAME $PERMISSION >> "$LOG_FILE"; then
            echo "Permission granted using pm grant" >> "$LOG_FILE"
         else
            echo "Permission grant failed, falling back to appops" >> "$LOG_FILE"
            appops set $PACKAGE_NAME $PERMISSION allow >> "$LOG_FILE"
         fi
      fi
   done
}

set_custom_package_perms()
{
	# Set up custom package permissions

	current_user="0"

	# MicroG: com.google.android.gms
	is_microg=$(dumpsys package com.google.android.gms | grep -m 1 -c org.microg.gms)
	if [ $is_microg -eq 1 ]; then
		exists_gms=$(pm list packages com.google.android.gms | grep -c com.google.android.gms)
		if [ $exists_gms -eq 1 ]; then
			pm grant com.google.android.gms android.permission.ACCESS_FINE_LOCATION
			pm grant com.google.android.gms android.permission.READ_EXTERNAL_STORAGE
			pm grant com.google.android.gms android.permission.ACCESS_BACKGROUND_LOCATION
			pm grant com.google.android.gms android.permission.ACCESS_COARSE_UPDATES
			pm grant --user $current_user com.google.android.gms android.permission.FAKE_PACKAGE_SIGNATURE
			appops set com.google.android.gms android.permission.FAKE_PACKAGE_SIGNATURE
			pm grant --user $current_user com.google.android.gms android.permission.MICROG_SPOOF_SIGNATURE
			appops set com.google.android.gms android.permission.MICROG_SPOOF_SIGNATURE
			pm grant --user $current_user com.google.android.gms android.permission.WRITE_SECURE_SETTINGS
			appops set com.google.android.gms android.permission.WRITE_SECURE_SETTINGS
			pm grant com.google.android.gms android.permission.SYSTEM_ALERT_WINDOW
			pm grant --user $current_user com.google.android.gms android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
			appops set com.google.android.gms android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
		fi
		exists_vending=$(pm list packages com.google.android.vending | grep -c com.google.android.vending)
		if [ $exists_vending -eq 1 ]; then
			pm grant --user $current_user com.google.android.vending android.permission.FAKE_PACKAGE_SIGNATURE
			appops set com.google.android.vending android.permission.FAKE_PACKAGE_SIGNATURE
		fi
	fi

}

if [ ! "$BUILD_DATETIME" == "$POST_INST_NUM" ]; then
	# Bliss user_apps
	for apk in $USER_APPS
	do		
		# pm install $apk
		install_apk $(basename $apk)
	done
	set_custom_package_perms
	rm "$POST_INST"
	touch "$POST_INST"
	echo $BUILD_DATETIME > "$POST_INST"
fi


