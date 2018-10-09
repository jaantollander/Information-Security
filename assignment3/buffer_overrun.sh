#!/usr/bin/env bash
KEYPHRASE="01234567890123456789"  # KEYLEN 20 (+1 null byte)
USERNAME="452056"
COMMAND="01234567890123456789012"  # 40-9-6-2=24 (+1 null byte)
CLIENTCMDTAG="ClientCmd"

echo "${CLIENTCMDTAG}|${USERNAME}|${COMMAND}" > /tmp/hmac_string.in
HEX_HMAC=$(openssl dgst -sha256 -hmac ${KEYPHRASE} /tmp/hmac_string.in | \
           grep -P -o '(?<== )[[:alnum:]]+')

echo "${USERNAME};${COMMAND}${KEYPHRASE};${HEX_HMAC}"$'\n' > /tmp/msg.in
nc device1.vikaa.fi 33892 < /tmp/msg.in

echo
echo
echo "Inputs:"
echo ${KEYPHRASE}
echo ${USERNAME}
echo ${COMMAND}
echo $(cat /tmp/hmac_string.in)
echo ${HEX_HMAC}
echo $(cat /tmp/msg.in)
