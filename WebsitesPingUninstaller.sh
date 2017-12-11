echo "####################################################"
echo "#   Uninstalling WebsitesPing by Jason Skipper     #"
echo "####################################################"

echo ""
echo "Removing the Application file from /Applications"

rm -R /Applications/WebsitesPing

echo ""
sleep 2
echo "Removing the Launch Agent"
echo ""
sleep 2
echo "You have successfully removed WebsitesPing! You must restart in order to finish the uninstall."

rm ~/Library/LaunchAgents/WebsitesPing.plist

launchctl unload ~/Library/LaunchAgents/WebsitesPing.plist

echo ""
tput setaf 1
sleep 1
echo "Thank you $USER! Have a great day. You must restart your computer in order for WebsitesPing to stop monitoring your websites. You may hit \"RETURN\" to close this window. "
tput sgr0
tput bold
read -p "" CLOSE
tput sgr0
echo ""
