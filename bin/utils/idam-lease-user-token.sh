#!/usr/bin/env bash

set -eu

username=${1}
password=${2}
clientSecret=${CCD_API_GATEWAY_IDAM_CLIENT_SECRET:-ccd_gateway_secret}
redirectUri=${CCD_IDAM_REDIRECT_URL:-http://localhost:3451/oauth2redirect}


curl --insecure --fail --show-error --silent -X POST -H "Content-Type: application/x-www-form-urlencoded"  "${IDAM_API_BASE_URL:-http://localhost:5000}/o/token" -d "client_id=ccd_gateway&client_secret=${clientSecret}&grant_type=password&password=${password}&scope=openid%20profile%20roles&username=${username}" | docker run --rm --interactive stedolan/jq -r .access_token
