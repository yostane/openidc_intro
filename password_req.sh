#!/bin/sh

rm -r tmp/grant_password
mkdir -p tmp/grant_password

curl -X POST \
    -d "client_id=$CLIENT_ID&grant_type=password&username=$USERNAME&password=$PASSWORD&scope=openid" \
    --url "$TOKEN_URL" | json_pp > tmp/grant_password/res.tmp

TOKEN=$(jq -r '.id_token' tmp/grant_password/res.tmp)
echo "id_token: " $TOKEN
echo $TOKEN > tmp/grant_password/id_token.tmp

pyjwt decode --no-verify $TOKEN | json_pp > tmp/grant_password/decoded_id_token.tmp
echo "decoded: " $DECODED
cat tmp/grant_password/decoded_id_token.tmp