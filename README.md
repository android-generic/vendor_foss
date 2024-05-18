# vendor_foss
A set of FOSS applications to include in an AOSP, now with new list of apps provided by HMTheBoy154.

*with added options and features*

## Features:

 - Supports F-Droid Mirrors - So if main repo fails, it will try the 
   rest of the mirrors from the F-Droid mirror list
 - Supports both arm64-v8a, x86 & x86_64 ABIs through the use of Options
 - Generates foss-permissions.xml for including into AOSP based builds
 
##### Options Usage:
	 
	**If no option is passed, it will prompt you to make a choice**
	 
	 $ bash update.sh X
	 
	- 1 = x86_64 ABI **default options**
	- 2 = arm64-v8a ABI
	- 3 = x86 ABI

##### AOSP Build Instructions:

To include the FOSS apps into your device specific builds. Please clone 
this repo into vendor/foss:

	$ git clone https://github.com/supremegamers/vendor_foss vendor/foss
	
Then add this inherit to your device tree:

	# foss apps
	$(call inherit-product-if-exists, vendor/foss/foss.mk)

## Included Apps:

#### From F-Droid Repo:

- Aurora App Store - com.aurora.store
- Neo-Store - com.machiav3lli.fdroid
- DAVx⁵ - at.bitfire.davdroid
- LocalGsmNlpBackend - org.fitchfamily.android.gsmlocation
- Talkback - com.android.talkback
- eSpeak - com.reecedunn.espeak

#### From Bromite Repo (if enabled):
- Bromite SystemWebView - org.bromite.webview

#### From MicroG Repo:

- MicroG GMS - com.google.android.gms
- MicroG GSF - com.google.android.gsf
- MicroG FakeStore - com.android.vending
- MicroG DroidGuard - org.microg.gms.droidguard 

### Notes

- For microG, **Singature Spoofing is required**, If your builds don't have it yet look around  [microG repo](https://github.com/microg/patches) for the Signature Spoofing patches.
- For Bromite SystemWebview, **please remember to add it into config_webview_packages.xml alongside with the signature**. You can visit [Bromite's Installing SystemWebView](https://github.com/bromite/bromite/wiki/Installing-SystemWebView) for more info.
