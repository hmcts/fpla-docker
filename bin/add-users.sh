#!/usr/bin/env bash

set -eu

dir=$(dirname ${0})

jq -r '.[] | .email + " " + .roles + " " +  .lastName + " " +  .firstName' ${dir}/users.json | while read args; do
  ${dir}/utils/idam-create-caseworker.sh $args
done

printf "\nGenerating local wiremock users mappings\n"
${dir}/utils/generate-local-user-mappings.sh