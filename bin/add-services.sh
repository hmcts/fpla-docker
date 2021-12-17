#!/usr/bin/env bash

set -eu

dir=$(dirname ${0})

${dir}/utils/idam-create-service.sh "ccd_data_store_api" "ccd_data_store_api" "idam_data_store_client_secret" "http://ccd-data-store-api/oauth2redirect" "false" "profile openid roles manage-user"

${dir}/utils/idam-create-service.sh "fpl" "fpl" "OOOOOOOOOOOOOOOO" "https://localhost:9000/oauth2/callback"

${dir}/utils/idam-create-service.sh "xui_webapp" "xui_webapp" "OOOOOOOOOOOOOOOO" "http://localhost:3333/oauth2/callback" "false" "profile openid roles manage-user create-user search-user"

${dir}/utils/idam-create-service.sh "adoption" "adoption" "adoption" "https://localhost:3000/landing" "true"

${dir}/utils/idam-create-service.sh "aac_manage_case_assignment" "aac_manage_case_assignment" "AACAACAACAACAACA" "https://manage-case-assignment/oauth2redirect" "false" "profile openid roles manage-user"

${dir}/utils/idam-create-service.sh "ccd_case_document_am_api" "ccd_case_document_am_api" "CDAMCDAMCDAMCDAM" "https://ccd-case-document-am-api/oauth2redirect" "false" "profile openid roles manage-user"
