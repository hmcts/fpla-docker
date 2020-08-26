#!/usr/bin/env bash

set -eu

definition_processor_version=latest

definition_dir=${1}
definition_output_file=${2}
additionalParameters=${3-}

definition_input_dir=${definition_dir}

if [[ ! -e ${definition_output_file} ]]; then
   touch ${definition_output_file}
fi

docker run --rm --name json2xlsx \
  -v ${definition_input_dir}:/tmp/jenkins-agent/ccd-definition \
  -v ${definition_output_file}:/tmp/jenkins-agent/ccd-definition.xlsx \
  -e CCD_DEF_CASE_SERVICE_BASE_URL=${CCD_DEF_CASE_SERVICE_BASE_URL:-http://docker.for.mac.localhost:4000} \
  hmctspublic.azurecr.io/ccd/definition-processor:${definition_processor_version} \
  json2xlsx -D /tmp/jenkins-agent/ccd-definition -o /tmp/jenkins-agent/ccd-definition.xlsx ${additionalParameters}
