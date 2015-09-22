#!/bin/sh
oathtool -v >/dev/null 2>&1 || { echo >&2 "I require oathtool but it's not installed.  Aborting. (install oathtool (debian) or oath-toolkit (arch) or similar"; exit 1; }

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ -z "$1" ]; then
  echo "call as "$0" PROVIDER user domain.tld"
else
  PROVIDER=$1
  user=$2
  LABEL=$3
  secretkey="$(openssl rand -hex 20)"
  touch /etc/users.oath
  chmod 0600 /etc/users.oath
  echo "HOTP/T30 "$user" - "$secretkey >> /etc/users.oath
  echo "added user credentials to /etc/users.oath"
  b32key="$(oathtool --verbose --totp $secretkey | grep -o -P '[A-Z0-9]{32}')"
  echo ""
  echo "run on a system with gui (don't forget to install qrencode first)"
  echo "---"
  echo "     qrencode -m 1 -s 5 'otpauth://totp/"$PROVIDER":"$user"@"$LABEL"?secret="$b32key"&period=30&digits=6&issuer="$PROVIDER"&algorithm=SHA1' -o ./qrcode"
  echo "---" 
  echo "" 
  echo "don't forget to clean your shell history"
  echo "open the qrcode file and scan it with the freeotp/yubikey authenticator/google authenticator app"
  unset secretkey
  unset b32key

  echo ""
  echo "For debian run:"
  echo ""
  echo "vim /etc/pam.d/common-auth"
  echo ""
  echo "put on top of stack, take care to adjust the success number to be one higher than the one in the line above which you posted the new line:"
  echo "---"
  echo "     auth    [success=2 default=ignore]      pam_oath.so usersfile=/etc/users.oath window=20"
  echo "---"
  echo ""
  echo "For arch you'll have to figure it out yourself"

  echo ""
  echo "run to install:"
  echo "  debian:"
  echo "     apt-get install oathtool liboath0"
  echo "  arch:"
  echo "     pacman -S oath-toolkit"
fi
