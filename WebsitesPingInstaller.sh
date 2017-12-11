#!/bin/bash
tput clear

tput setaf 1
echo ""
echo "####################################################"
echo "#    Setting up WebsitesPing by Jason Skipper      #"
echo "####################################################"
echo ""
tput sgr0
echo "Please Enter your name and press [ENTER]: "
echo ""
tput bold
read -p "Name: " CURRENTUSER
tput sgr0
tput setaf 4
echo ""
echo "Hello $CURRENTUSER. This Script will Help You Set Up WebsitesPing on your computer. I need to ask you a few questions first before we get started."
echo ""
echo "Enter the E-Mail Address that you would like for notifications to be sent TO and press [ENTER]: "
echo ""
tput sgr0
tput bold
read -p "E-Mail: " USER_EMAIL
tput sgr0
echo ""
tput setaf 4
echo "We will now enter the first DOMAIN that you would like to ping."
tput sgr0

MOREDOMAINS="N"
DOMAINS_TO_ENCRYPT=()
COUNTER=0

function regdomain {
  echo ""
  tput setaf 4
  echo  "Please use the Domain name that you would like to monitor (ex: example.com, www.example.com). Enter your Domain or SubDomain Name and press [ENTER]: "
  tput sgr0
  tput bold
  echo ""
  read -p "Domain: " DOMAIN_NAME[$COUNTER]
  tput sgr0

  #Just making sure that they didn't put www before the domain name.
  DOMAIN_NAME[$COUNTER]=$(sed 's/https.//g' <<<"${DOMAIN_NAME[$COUNTER]}")
  DOMAIN_NAME[$COUNTER]=$(sed 's/http.//g' <<<"${DOMAIN_NAME[$COUNTER]}")
  DOMAIN_NAME[$COUNTER]=$(sed 's/\/.//g' <<<"${DOMAIN_NAME[$COUNTER]}")
  tput setaf 4
  echo ""
  echo "Let me check to make sure that ${DOMAIN_NAME[$COUNTER]} is valid and is working correctly."
  echo ""
  tput setaf 1
  ping -c 3 ${DOMAIN_NAME[$COUNTER]}
  tput setaf 4

  if ping -c 1 ${DOMAIN_NAME[$COUNTER]} &> /dev/null
  then
    DOMAINS_TO_ENCRYPT+=("-d ${DOMAIN_NAME[$COUNTER]}")
    echo ""
    echo "Great! I was able to connect successfully to ${DOMAIN_NAME[$COUNTER]}!"

    sendTestEmail

    tput sgr0

    tput setaf 4
    until ask "Did you receive an email at $USER_EMAIL? (It may take a few minutes to arrive.) Please enter [Y] or [N] and press [ENTER]: "$(tput sgr0) $(tput bold); do
      echo ""
      tput setaf 4
      echo "E-mail send from terminal isn't set up correctly. Let's do that now!"
      tput sgr0
      setupTerminalEmailSend
      sleep 4
      tput setaf 4
      sendTestEmail
      tput sgr0
    done
    tput sgr0

    echo ""
    tput setaf 4
    echo "Great! Let's Continue..."
    tput sgr0
    echo ""

    let COUNTER=COUNTER+1

    if ask "Do you have any other domains or subdomains that you would like to include at this time? Please enter [Y] or [N] and press [ENTER]: "$(tput sgr0) $(tput bold); then
      regdomain
    fi
  else
    echo ""
    echo "WARNING: COULD NOT CONNECT TO ${DOMAIN_NAME[$COUNTER]}. Please check the web address that you would like to ping and then run this installer again. Thank you."
    exit 1
  fi

  tput sgr0
}

function sendTestEmail {
  echo "${DOMAIN_NAME[$COUNTER]} Server succeeded at $(date)" | mail -s "${DOMAIN_NAME[$COUNTER]} Server Up" $USER_EMAIL
  echo ""
  echo "Sending a test email to $USER_EMAIL..."
  echo ""
}

function setupTerminalEmailSend {
  echo ""
  tput setaf 4
  echo  "Please enter the SMTP settings for the E-Mail Address that you would like to send notifications FROM and press [ENTER]. This information is necessary to set up SMTP sending from Terminal. (This will edit your local computer's /etc/postfix/main.cf and /etc/postfix/sasl_passwd files): "
  tput sgr0
  tput bold
  echo ""
  read -p "E-Mail Address: " EMAILSEND
  read -p "SMTP Server Name (ex: smtp.office365.com): " SMTPSERVER
  read -p "SMTP Port Number (ex: 587): " SMTPPORT
  read -p "E-Mail Password: " SMTPPASSWD
  echo ""
  tput sgr0

  if [[ $SMTPSERVER == *"gmail.com"* ]]; then
    echo "NOTE: In order to send e-mail through Google's servers, it is necessary to enable Access to Less Secure Apps. Please Visit https://myaccount.google.com/lesssecureapps, sign into the account that you wish to send e-mail from, and then enable the option \" Allow less secure apps:\". Please do this before continuing installation."

    echo ""

    until ask "Have you enabled the option \"Allow less secure apps\" for your e-mail address?"; do
      echo "This step is ESSENTIAL. Please Visit https://myaccount.google.com/lesssecureapps, sign into the account that you wish to send e-mail from, and then enable the option \" Allow less secure apps:\". Please do this before continuing installation."
      echo ""
    done

    echo "Great! Let's continue... "
    sleep 1
  fi

  tput setaf 4
  echo "Updating /etc/postfix/main.cf... Please enter your Computer Password to continue"
  tput sgr0
  echo ""
  sudo sed -i '' '/relayhost/d' /etc/postfix/main.cf
  sudo sed -i '' '/smtp_sasl_auth_enable/d' /etc/postfix/main.cf
  sudo sed -i '' '/smtp_sasl_password_maps/d' /etc/postfix/main.cf
  sudo sed -i '' '/smtp_sasl_security_options/d' /etc/postfix/main.cf
  sudo sed -i '' '/smtp_sasl_mechanism_filter/d' /etc/postfix/main.cf
  sudo sed -i '' '/smtp_use_tls/d' /etc/postfix/main.cf
  sudo sed -i '' '/smtp_tls_security_level/d' /etc/postfix/main.cf
  sudo sed -i '' '/tls_random_source/d' /etc/postfix/main.cf
  sudo sed -i '' '/smtp_generic_maps/d' /etc/postfix/main.cf
  sudo sed -i '' '/inet_protocols/d' /etc/postfix/main.cf

  cp /etc/postfix/main.cf main.cf

  echo "relayhost=$SMTPSERVER:$SMTPPORT" >> main.cf
  echo "smtp_sasl_auth_enable=yes" >> main.cf
  echo "smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd" >> main.cf
  echo "smtp_sasl_security_options=noanonymous" >> main.cf
  echo "smtp_sasl_mechanism_filter=login" >> main.cf
  echo "smtp_use_tls=yes" >> main.cf
  echo "smtp_tls_security_level=encrypt" >> main.cf
  echo "tls_random_source=dev:/dev/urandom" >> main.cf
  echo "inet_protocols = all" >> main.cf

  if [[ $SMTPSERVER == *"office365.com"* ]]; then
    echo "$USER@$(hostname)     $EMAILSEND" >> generic
    echo ""
    sudo cp generic /etc/postfix/generic
    rm generic
    sudo postmap /etc/postfix/generic
    sudo chown root:wheel /etc/postfix/generic /etc/postfix/generic.db
    sudo chmod 600 /etc/postfix/generic /etc/postfix/generic.db
    echo "smtp_generic_maps = hash:/etc/postfix/generic" >> main.cf
    echo "smtp_always_send_ehlo = yes" >> main.cf
    echo "smtp_sasl_tls_security_options = noanonymous" >> main.cf
    sed -i '' '/inet_protocols/d' main.cf
    echo "inet_protocols = ipv4" >> main.cf
    sed -i '' '/smtp_tls_security_level=encrypt/d' main.cf
    echo "smtp_tls_security_level=may" >> main.cf
    echo "" >> main.cf
  fi

  sudo cp main.cf /etc/postfix/main.cf
  rm main.cf

  sleep 1
  echo ""
  tput setaf 4
  echo "Updating /etc/postfix/sasl_passwd..."
  tput sgr0
  echo ""

  sudo rm /etc/postfix/sasl_passwd > /dev/null

  echo "$SMTPSERVER:$SMTPPORT $EMAILSEND:$SMTPPASSWD" >> sasl_passwd

  sudo cp sasl_passwd /etc/postfix/sasl_passwd
  rm sasl_passwd

  sleep 1

  sudo postmap /etc/postfix/sasl_passwd
  sudo chown root:wheel /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
  sudo chmod 600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db

  sudo postfix stop > /dev/null
  sudo postfix start

}

ask() {
    # http://djm.me/ask
    local prompt default REPLY

    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read REPLY </dev/tty

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

COUNT=4

regdomain
tput setaf 4
echo ""
echo "Updating the WebsitesPing Script File"
echo ""

rm -R /Applications/WebsitesPing > /dev/null

mkdir /Applications/WebsitesPing

cat >> /Applications/WebsitesPing/WebsitesPing.sh <<EOF
#!/bin/bash
DOMAINS=(${DOMAIN_NAME[@]})

COUNT=$COUNT
USER_EMAIL=$USER_EMAIL

EOF

cat >> /Applications/WebsitesPing/WebsitesPing.sh <<\EOF
for i in ${DOMAINS[@]}; do
  if ping -c "$COUNT" $i;
  then
  #  echo "$i Server succeeded at $(date)" | mail -s "$i Server Up" $USER_EMAIL
    echo ""
    echo "sending email to" $USER_EMAIL
    echo "$i Server succeeded at $(date)"
    echo ""
  else
    echo "$i Server failed at $(date)" | mail -s "$i Server Down" $USER_EMAIL
    echo ""
    echo "\e[91mLight red $i Server failed at $(date)"
    echo ""
  fi
done

echo -e "Ran Successfully at $(date)" >> /Applications/WebsitesPing/WebsitesPing.log

EOF

echo "Making the new Script Executable"

chmod +x /Applications/WebsitesPing/WebsitesPing.sh
sleep 2

echo ""
echo "Creating LaunchAgent....................."
echo ""

rm ~/Library/LaunchAgents/WebsitesPing.plist
cat >> ~/Library/LaunchAgents/WebsitesPing.plist << EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>WebsitesPing</string>
        <key>StartInterval</key>
        <integer>900</integer>
        <key>Program</key>
        <string>/Applications/WebsitesPing/WebsitesPing.sh</string>
        <key>RunAtLoad</key>
        <true/>
    </dict>
</plist>
EOF
sleep 2
echo "Registering the Launch Agent"
echo ""

launchctl load ~/Library/LaunchAgents/WebsitesPing.plist
sleep 2
echo ""
tput setaf 1
echo "DONE! Thank you $CURRENTUSER. Have a great day. You must restart your computer in order for WebsitesPing to begin monitoring your websites. You may hit \"RETURN\" to close this window. "
tput sgr0
tput bold
read -p "" CLOSE
exit 1
