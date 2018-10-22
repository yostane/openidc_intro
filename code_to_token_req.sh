#!/bin/sh

# requires jq, json-pp
# pip install pyjwt

rm -r tmp/auth_code
mkdir -p tmp/auth_code

echo $TOKEN_URL

curl --request POST \
  --url "$TOKEN_URL" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --header 'Accept: application/json' \
  --data "grant_type=authorization_code" \
  --data "client_id=$CLIENT_ID" \
  --data "client_secret=" \
  --data "code=$AUTH_CODE" \
  --data "redirect_uri=$REDIRECT_URI" | json_pp > tmp/auth_code/res.tmp

TOKEN=$(jq -r '.id_token' tmp/auth_code/res.tmp)
echo "id_token: " $TOKEN
echo $TOKEN > tmp/auth_code/id_token.tmp

pyjwt decode --no-verify $TOKEN | json_pp > tmp/auth_code/decoded_id_token.tmp
echo "decoded: " $DECODED
cat tmp/auth_code/decoded_id_token.tmp
