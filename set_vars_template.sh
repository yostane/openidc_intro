#!/bin/sh

# executes the different scripts. You just need to fill the info
rm -rf tmp

export TOKEN_URL=
export CLIENT_ID=
export USERNAME=
export PASSWORD=

# password grant
./password_req.sh

export REDIRECT_URI=
export AUTH_CODE=

# authrozation code
./code_to_token_req.sh