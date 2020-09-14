#!/usr/bin/env bash

set -eu

dir=$(dirname ${0})

CLIENT_ID=${1}
LABEL=${2}
CLIENT_SECRET=${3}
REDIRECT_URL=${4}
SELF_REGISTRATION=${5:-"false"}
SCOPE=${6:-"openid profile authorities acr roles search-user"}

apiToken=$(${dir}/idam-authenticate.sh "${IDAM_ADMIN_USER}" "${IDAM_ADMIN_PASSWORD}")

echo -e "\nUpdate service with ID: ${CLIENT_ID}\nLabel: ${LABEL}\nClient Secret: ${CLIENT_SECRET}\nRedirect URL: ${REDIRECT_URL}\n"

STATUS=$(curl --silent --output /dev/null --write-out '%{http_code}' -X PUT -H 'Content-Type: application/json' -H "Authorization: AdminApiAuthToken ${apiToken}" \
  ${IDAM_API_BASE_URL:-http://localhost:5000}/services/${CLIENT_ID} \
  -d '{
    "allowedRoles": [],
    "description": "'${LABEL}'",
    "label": "'${LABEL}'",
    "oauth2ClientSecret": "'${CLIENT_SECRET}'",
    "oauth2RedirectUris": ["'${REDIRECT_URL}'"],
    "oauth2Scope": "'"${SCOPE}"'",
    "selfRegistrationAllowed": "'${SELF_REGISTRATION}'"
}')

if [ $STATUS -eq 200 ]; then
  echo "Service update sucessfully"
else
  echo "ERROR: HTTPCODE = $STATUS"
  exit 1
fi
