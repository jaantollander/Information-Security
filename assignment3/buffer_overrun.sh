#!/usr/bin/env bash
KEYPHRASE=01234567890123456789
USERNAME=452056
COMMAND=01234567890123456789012

echo "ClientCmd|${USERNAME}|${COMMAND}" > /tmp/hmac_string.in
HEX_HMAC=$(openssl dgst -sha256 -hmac ${KEYPHRASE} /tmp/hmac_string.in | \
           grep -P -o '(?<== )[[:alnum:]]+')

echo ${KEYPHRASE}
echo ${USERNAME}
echo ${COMMAND}
echo $(cat /tmp/hmac_string.in)
echo ${HEX_HMAC}

echo "${USERNAME};${COMMAND}${KEYPHRASE};${HEX_HMAC}"$'\n' > /tmp/msg.in
echo $(cat /tmp/msg.in)

nc device1.vikaa.fi 33892 < /tmp/msg.in

echo
