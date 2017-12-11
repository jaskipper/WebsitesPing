# WebsitesPing - For OSX
**Written By Jason Skipper**

WebsitePing is a program that will periodically check to see if websites are up and running, and if at some moment a website is down, it will email a notification to the user.

## Installation:

* Unzip the WebsitePing_vX.XX.zip file.
* Run the WebsitePingInstall.sh file
* Right click on the file
* Open With…
* Choose “Terminal” (If not in listed Applications, choose “Other”, uncheck “Recommended Applications” and then choose Terminal)
* Go through the Setup

## What Does This Do?

* Installs the Application under /Applications/WebsitePing/WebsitesPing.sh
* Installs a script with instructions to run every 15 minutes under ~/Library/LaunchAgents/WebsitesPing.plist

## How to Add New Websites?

* Re-Run the Installer
* Restart Your Machine

## How to Know That It Is Working?

* You will receive an email if any of your websites go down.
* You can see all successful tries in the Log file that is found in /Applications/WebsitesPing/WebsitesPing.log

## How to Uninstall?

* Run the WebsitesPingUninstaller.sh provided in the Zip file.
