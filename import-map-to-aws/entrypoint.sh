#!/bin/bash
set -e

# Deploys an import-map.json to an S3 bucket and invalidates the Cloudfront object
if [ -z "$AWS_BUCKET_NAME" ]; then
  echo "AWS_BUCKET_NAME is not set"
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set"
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set"
  exit 1
fi

if [ -z "$IMPORT_MAP_URL" ]; then
  echo "IMPORT_MAP_URL is not set"
  exit 1
fi

if [ -z "$S3_KEY" ]; then
  S3_KEY="qmfe"
fi

if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

if [ -z "$DRY_RUN" ]; then
  DRY_RUN='false'
fi

if [ -z "$CACHE_CONTROL" ]; then
  CACHE_CONTROL='public,max-age=5,s-maxage=300'
fi

if [ -z "$FILE_NAME" ]; then
  FILE_NAME='import-map.json'
fi

echo "Running qmfe-to-aws with the following environment variables:"
echo "AWS_BUCKET_NAME                  $AWS_BUCKET_NAME"
echo "AWS_ACCESS_KEY_ID:               $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY:           $AWS_SECRET_ACCESS_KEY"
echo "AWS_REGION:                      $AWS_REGION"
echo "IMPORT_MAP_URL:                  $IMPORT_MAP_URL"
echo "S3_KEY:                          $S3_KEY"
echo "EXCLUDE:                         $EXCLUDE"
echo "TRANSFORM:                       $TRANSFORM"
echo "DRY_RUN:                         $DRY_RUN"
echo "CACHE_CONTROL:                   $CACHE_CONTROL"
echo "FILE_NAME:                       $FILE_NAME"
echo ""

deploy_import_map() {

  # check if import-map exist
  [ ! -f "./$FILE_NAME" ] && echo "./$FILE_NAME does not exists." && exit 1

  # set some useful VARIABLES
  local -r s3_base="s3://$AWS_BUCKET_NAME/$S3_KEY" # -> s3://s3-bucket/qmfe
  local -r aws_s3_bucket_import_map_url="$s3_base/$FILE_NAME" # -> s3://s3-bucket/qmfe/import-map.json
  local -r aws_s3_metrics_url="$s3_base/metrics" # -> s3://s3-bucket/qmfe/import-map.json
  local -r invalidation_path="/$S3_KEY/$FILE_NAME" # -> /qmfe/import-map.json
  local -r aws_profile="qcs-cdn"
  local -r history_folder="${FILE_NAME%.json}-history"

  local dryrun
  [[ $DRY_RUN = "true" ]] && dryrun="--dryrun"


  aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$aws_profile"
  aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$aws_profile"

  # prepare upload by removing entries from exclude input and transform transform input
  # remove entries
  local -a remove_entries_array=()
  if [ -n "$EXCLUDE" ]; then
      IFS=',' read -r -a remove_entries_array <<< "$EXCLUDE"
  fi

  # let's build up a command with jq del

  # get length of an array
  local -r -i tLen=${#remove_entries_array[@]}
  local command="";
  if [ "$tLen" -gt 0 ]; then
    command="jq 'del("
    for (( i=0; i<tLen; i++ ));
    do
        echo "Omitting ${remove_entries_array[$i]} from import-map"
        if [ "$i" -gt 0 ]; then
            command="$command,"
        fi
        command="${command}.imports.\"${remove_entries_array[$i]}\""
    done
    # command now looks like similar to this jq 'del(.imports."@qmfe/hub",.imports."@qmfe/automations")'
    # finish with applying sed_transform and send it to a temp file deploy-import-map.json
    command="$command)' $FILE_NAME"
  else
    command="cat $FILE_NAME"
  fi
  # apply sed transform if given
  if [ -n "$TRANSFORM" ]; then
    command="$command | sed '$TRANSFORM'"
  fi

  # dump command output to temp file
  command="$command > deploy-import-map.json"
  eval "$command"

  # verify that the files import map urls points to exist
  # this assumes that all import-map entries comes from the same S3 bucket
  local -a cdn_urls=()

  while IFS='' read -r line; do cdn_urls+=("$line"); done < <(jq -r '.imports | values[]' deploy-import-map.json)
  echo "Validate that import-map entries are pointing to files that exist"
  for url in "${cdn_urls[@]}"; do
      if [[ "$url" == */ ]]; then
          # skip this check if url entry points to folder
          continue
      fi
      local -i curl_response
      curl_response=$(curl --head --write-out "%{http_code}\n" --silent --output /dev/null "$url")
      if [ "$curl_response" == 200 ]; then
          echo "$url >>>>> import map entry is valid <<<<<"
      else
          echo "$url >>>>> import map entry is INVALID <<<<<"
          echo "import-map will NOT be deployed"
          exit 1
      fi

  done

  # ok everything is set

  echo "Will deploy"
  cat deploy-import-map.json
  echo "to $aws_s3_bucket_import_map_url"

  # Upload import-map to history folder
  echo "Upload import-map to history folder"
  aws s3 cp deploy-import-map.json "$s3_base/$history_folder/$(date "+%Y.%m.%d-%H.%M.%S").$FILE_NAME" --profile $aws_profile $dryrun --region $AWS_REGION

  # does import-map exist in s3?
  local -r -i file_exist="$(aws s3 ls "$aws_s3_bucket_import_map_url" --recursive --summarize --profile "$aws_profile" --region $AWS_REGION | grep 'Total Objects: ' | sed 's/[^0-9]*//g')"
  local locked="false"

  if [[ "$file_exist" -gt 0 ]]; then
    # Check if import-map file has a locked attribute in S3 meta-data
    locked=$(aws s3api head-object --bucket "$AWS_BUCKET_NAME" --key "$S3_KEY/$FILE_NAME" --profile "$aws_profile" --region $AWS_REGION | jq .Metadata.locked)
  fi
  locked="\"true\""
  # Upload import-map to default folder if file is NOT locked
  if [[ "$locked" == "\"true\"" ]]; then
    echo "$aws_s3_bucket_import_map_url is locked - new version of import-map could not be applied."
    # Set output to locked 
    echo "::set-output name=import-map-state::locked"
  else
    echo "Deploy import-map to $aws_s3_bucket_import_map_url"
    aws s3 cp deploy-import-map.json "$aws_s3_bucket_import_map_url" --cache-control "$CACHE_CONTROL" --profile $aws_profile --region $AWS_REGION $dryrun
    # create metrics file
    echo "Upload metrics to $aws_s3_metrics_url"

    node ../../translate-import-map-to-metrics.js $FILE_NAME > metrics
    aws s3 cp metrics "$aws_s3_metrics_url" --cache-control no-cache --profile $aws_profile --region $AWS_REGION $dryrun
    if [ -n "$AWS_DISTRIBUTION_ID" ]; then
      # invalidate S3 object to fetch origin from S3 bucket
      command="aws cloudfront create-invalidation --distribution-id $AWS_DISTRIBUTION_ID --paths $invalidation_path --profile $aws_profile --region $AWS_REGION"

      if [[ $DRY_RUN = "true" ]]; then
        echo "(dryrun) $command"
        echo "(dryrun) curl $IMPORT_MAP_URL"
      else
        echo "invalidating import-map.json file at cloudfront"
        eval "$command"
        # curl the file to warm up the cache
        curl "$IMPORT_MAP_URL"
      fi
    fi
  fi
}

cleanup() {
    echo "cleaning up"
    rm -rf deploy-import-map.json
}
trap cleanup EXIT

deploy_import_map "$@"
