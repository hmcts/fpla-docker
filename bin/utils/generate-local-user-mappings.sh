#!/bin/sh

set -eu

dir=$(dirname ${0})
root_dir=$(realpath ${dir}/../..)

mappings_template_dir=${root_dir}/mocks/wiremock/templates
user_template_file=${mappings_template_dir}/userTemplate.json
mock_user_by_email_template=${mappings_template_dir}/userByEmail.json
mock_org_by_email_template=${mappings_template_dir}/organisationByEmial.json
mock_user_by_email_dir=${root_dir}/mocks/wiremock/mappings/user-by-email
mock_org_by_email_dir=${root_dir}/mocks/wiremock/mappings/prd/org-by-email
mock_file=${root_dir}/mocks/wiremock/__files/organisationUsers.json
mock_tmp_file=${root_dir}/mocks/wiremock/__files/organisationUsers.tmp.json
users_file=${root_dir}/bin/users.json
users_ids_tmp_file=${dir}/userIds.json.tmp

function query_db() {
  docker run -e PGPASSWORD='openidm' --rm --network ccd-network postgres:11-alpine psql --host shared-db  --username openidm --tuples-only  --command "$1" openidm
}

function get_users_email_id_mappings() {
  query_db "SELECT json_object(array_agg(fullobject->>'mail'), array_agg(fullobject->>'_id')) FROM managedObjects WHERE fullobject->>'mail' IS NOT NULL AND fullobject->>'userName' LIKE '%$1%';"
}


function create_mock_response() {
  jq --arg organisation $1 --argjson template "$(<$user_template_file)" '[.[] | select(.email | contains($organisation)) | $template + .]' $users_file > $mock_file
  echo $(get_users_email_id_mappings $1) > $users_ids_tmp_file

  for i in `seq 0 $(jq '. | length - 1' $mock_file)`
  do
    email=$(jq -r --argjson i $i '.[$i].email' $mock_file)
    user_id=$(jq -r --arg email $email '.[$email]' $users_ids_tmp_file)
    jq -r --argjson i $i --arg user_id $user_id '.[$i].userIdentifier=$user_id | .[$i].firstName=.[$i].email | .[$i].roles|=split(",")' $mock_file > $mock_tmp_file && mv $mock_tmp_file $mock_file
  done

  allUsers=$(jq ". | {users: .}" $mock_file)
  echo $allUsers | jq > $mock_file

  rm $users_ids_tmp_file
}

function create_user_by_email_responses() {
  rm -rf $mock_user_by_email_dir
  mkdir $mock_user_by_email_dir
  echo $(get_users_email_id_mappings '@') > $users_ids_tmp_file

  for i in `seq 0 $(jq '. | length - 1' $users_file)`
  do
    email=$(jq -r --argjson i $i '.[$i].email' $users_file)
    id=$(jq -r --arg email $email '.[$email]' $users_ids_tmp_file)

    if [ "$id" != "null" ]; then
       userByEmailMappings=$(sed -e "s|\[email]|$email|" -e "s|\[userId]|$id|" $mock_user_by_email_template)
       echo $userByEmailMappings | jq '.' > "$mock_user_by_email_dir/${email}.json"
    fi

  done

  rm $users_ids_tmp_file
}

function create_orgs_by_email_responses() {
  rm -rf $mock_org_by_email_dir
  mkdir $mock_org_by_email_dir
  echo $(get_users_email_id_mappings '@') > $users_ids_tmp_file

  orgs=("swansea" "hillingdon" "swindon" "wiltshire" "solicitors")
  for org in "${orgs[@]}"
  do
    for i in `seq 0 $(jq '. | length - 1' $users_file)`
    do
        email=$(jq -r --argjson i $i '.[$i].email' $users_file)

        if [[ $email == *"@${org}"* ]]; then
           userByEmailMappings=$(sed -e "s|\[email]|$email|" -e "s|\[org]|$org|" $mock_org_by_email_template)
           echo $userByEmailMappings | jq '.' > "$mock_org_by_email_dir/${email}.json"
        fi
    done
  done

  rm $users_ids_tmp_file
}

create_mock_response swansea
create_user_by_email_responses
create_orgs_by_email_responses
