#!/bin/sh

set -eu

dir=$(dirname ${0})
root_dir=$(realpath ${dir}/../..)

mappings_template_dir=${root_dir}/mocks/wiremock/templates
user_template_file=${mappings_template_dir}/userTemplate.json
mock_user_by_email_template=${mappings_template_dir}/userByEmail.json
mock_org_by_email_template=${mappings_template_dir}/organisationByEmail.json
mock_org_users_by_email_template=${mappings_template_dir}/organisationUsersByEmail.json
mock_user_by_email_dir=${root_dir}/mocks/wiremock/mappings/prd/user-by-email
mock_org_by_email_dir=${root_dir}/mocks/wiremock/mappings/prd/org-by-email
mock_org_users_by_email_dir=${root_dir}/mocks/wiremock/mappings/prd/org-users-by-email
mock_file=${root_dir}/mocks/wiremock/__files/organisationUsers.json
mock_file_dir=${root_dir}/mocks/wiremock/__files/prd/generated
mock_tmp_file=${root_dir}/mocks/wiremock/__files/prd/generated/organisationUsers.tmp.json
users_file=${root_dir}/bin/users.json
users_ids_tmp_file=${dir}/userIds.json.tmp
org_ids_file=${root_dir}/resources/org_id_mapping.json
orgs=("swansea" "hillingdon" "swindon" "wiltshire" "solicitors")

query_db() {
  docker run -e PGPASSWORD='openidm' --rm --network ccd-network postgres:11-alpine psql --host shared-db  --username openidm --tuples-only  --command "$1" openidm
}

function get_users_email_id_mappings() {
  query_db "SELECT json_object(array_agg(fullobject->>'mail'), array_agg(fullobject->>'_id')) FROM managedObjects WHERE fullobject->>'mail' IS NOT NULL AND fullobject->>'userName' LIKE '%$1%';"
}

create_users_in_org() {
  rm -rf $mock_file_dir
  mkdir -p $mock_file_dir

  for org in "${orgs[@]}"
  do
      mock_file=$mock_file_dir/${org}Users.json
      jq --arg organisation ${org} --argjson template "$(<$user_template_file)" '[.[] | select(.email | contains($organisation)) | $template + .]' $users_file > $mock_file
      echo $(get_users_email_id_mappings ${org}) > $users_ids_tmp_file

      for i in `seq 0 $(jq '. | length - 1' $mock_file)`
      do
        email=$(jq -r --argjson i $i '.[$i].email' $mock_file)
        user_id=$(jq -r --arg email $email '.[$email]' $users_ids_tmp_file)
        jq -r --argjson i $i --arg user_id $user_id '.[$i].userIdentifier=$user_id | .[$i].firstName=.[$i].email | .[$i].roles|=split(",")' $mock_file > $mock_tmp_file && mv $mock_tmp_file $mock_file
      done

      org_id=$(jq ".${org}" $org_ids_file)
      allUsers=$(jq ". | {organisationIdentifier: ${org_id}, users: .}" $mock_file)
      echo $allUsers | jq > $mock_file

      rm $users_ids_tmp_file
  done
}

create_user_by_email_mapping() {
  rm -rf $mock_user_by_email_dir
  mkdir -p $mock_user_by_email_dir
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

create_orgs_by_email_mapping() {
  rm -rf $mock_org_by_email_dir
  mkdir -p $mock_org_by_email_dir
  echo $(get_users_email_id_mappings '@') > $users_ids_tmp_file

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

create_orgs_users_by_email_mapping() {
  rm -rf $mock_org_users_by_email_dir
  mkdir -p $mock_org_users_by_email_dir
  echo $(get_users_email_id_mappings '@') > $users_ids_tmp_file

  for org in "${orgs[@]}"
  do
    for i in `seq 0 $(jq '. | length - 1' $users_file)`
    do
        email=$(jq -r --argjson i $i '.[$i].email' $users_file)

        if [[ $email == *"@${org}"* ]]; then
           userByEmailMappings=$(sed -e "s|\[email]|$email|" -e "s|\[org]|$org|" $mock_org_users_by_email_template)
           echo $userByEmailMappings | jq '.' > "$mock_org_users_by_email_dir/${email}.json"
        fi
    done
  done

  rm $users_ids_tmp_file
}

create_users_in_org
#create_user_by_email_mapping
#create_orgs_by_email_mapping
#create_orgs_users_by_email_mapping
