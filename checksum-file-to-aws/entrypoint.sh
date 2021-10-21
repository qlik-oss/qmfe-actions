#!/bin/bash
set -e

err_report() {
    echo "Error on line $1"
}

trap 'err_report $LINENO' ERR

#!/bin/bash
set -e

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set"
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set"
  exit 1
fi

if [ -z "$AWS_BUCKET" ]; then
  echo "AWS_BUCKET is not set"
  exit 1
fi

if [ -z "$FILE" ]; then
  echo "FILE is not set"
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

if [ -z "$DRY_RUN" ]; then
  DRY_RUN="false"
fi

echo "Running checksum-file-to-aws with the following environment variables:"
echo "AWS_BUCKET                  $AWS_BUCKET"
echo "AWS_ACCESS_KEY_ID:          $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY:      $AWS_SECRET_ACCESS_KEY"
echo "FILE:                       $FILE"
echo "AWS_REGION:                 $AWS_REGION"
echo "DRY_RUN:                    $DRY_RUN"

dryrun=""
[[ $DRY_RUN = "true" ]] && dryrun="--dryrun"

aws_profile="qcs-cdn"
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$aws_profile"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$aws_profile"

# generates md5 checksum and store to a file
checksum=$(md5sum "$FILE" | awk '{ print $1 }')
echo "" > "$checksum"

if [[ $(aws s3 ls "$AWS_BUCKET/$checksum" --profile $aws_profile | head) ]]; then
  echo -e "$AWS_BUCKET/$checksum already exists, will NOT upload to this one";
  rm -rf "$checksum"
  exit 0
fi

eval "aws s3 cp ./$checksum $AWS_BUCKET/ --region $AWS_REGION --profile $aws_profile $dryrun"
echo "Done, cleaning up"
rm -rf "$checksum"
