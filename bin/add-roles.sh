#!/usr/bin/env bash

set -eu

dir=$(dirname ${0})
echo "TEST 1"
${dir}/utils/idam-add-role.sh "ccd-import"
echo "TEST 2"
${dir}/utils/idam-add-role.sh "caseworker"
echo "TEST 3"
${dir}/utils/idam-add-role.sh "caseworker-publiclaw"
echo "TEST 4"
${dir}/utils/idam-add-role.sh "caseworker-adoption"
echo "TEST 5"

# User used during the CCD import and ccd-role creation
${dir}/utils/idam-create-caseworker.sh "ccd.docker.default@hmcts.net" "ccd-import"

echo "TEST 6"

roles=("solicitor" "courtadmin" "cafcass" "gatekeeper" "systemupdate" "judiciary" "bulkscan" "bulkscansystemupdate")
for role in "${roles[@]}"
do
echo "TEST 7"
	${dir}/utils/idam-add-role.sh "caseworker-publiclaw-${role}"
	echo "TEST 8"
  ${dir}/utils/ccd-add-role.sh "caseworker-publiclaw-${role}"
done

roles=("clerk")
for role in "${roles[@]}"
do
  ${dir}/utils/idam-add-role.sh "caseworker-adoption-${role}"
  ${dir}/utils/ccd-add-role.sh "caseworker-adoption-${role}"
done

${dir}/utils/ccd-add-role.sh "citizen"
