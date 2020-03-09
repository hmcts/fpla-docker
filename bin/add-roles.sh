#!/usr/bin/env bash

set -eu

dir=$(dirname ${0})

${dir}/utils/idam-add-role.sh "ccd-import"
${dir}/utils/idam-add-role.sh "caseworker"
${dir}/utils/idam-add-role.sh "caseworker-publiclaw"
${dir}/utils/idam-add-role.sh "caseworker-adoption"

# User used during the CCD import and ccd-role creation
${dir}/utils/idam-create-caseworker.sh "ccd.docker.default@hmcts.net" "ccd-import"

roles=("solicitor")
for role in "${roles[@]}"
do
	${dir}/utils/idam-add-role.sh "caseworker-publiclaw-${role}"
  ${dir}/utils/ccd-add-role.sh "caseworker-publiclaw-${role}"
done

roles=("clerk")
for role in "${roles[@]}"
do
  ${dir}/utils/idam-add-role.sh "caseworker-adoption-${role}"
  ${dir}/utils/ccd-add-role.sh "caseworker-adoption-${role}"
done

${dir}/utils/ccd-add-role.sh "citizen"
