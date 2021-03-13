#!/bin/bash

#echo "script path is $( dirname "${BASH_SOURCE[0]}" )"
HOSTNAME=`hostname -A`
PASSPHRASE=`pwgen 32 1`
if [ -z ${HOSTNAME+x} ] ||  [ -z ${PASSPHRASE+x} ]
then
  echo "Specify HOSTNAME and PASSPHRASE in environment variable"
  exit 1
fi
export GNUPGHOME="$(mktemp -d)"
gpg2 --batch --gen-key "$( dirname "${BASH_SOURCE[0]}" )/keyconfig.txt"
gpg2 --list-keys
echo "Passphrase = $PASSPHRASE"
unset GNUPGHOME
