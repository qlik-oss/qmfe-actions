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

if [ -z "$AWS_BUCKET_NAME" ]; then
  echo "AWS_BUCKET_NAME is not set"
  exit 1
fi

if [ -z "$QMFE_ID" ]; then
  echo "QMFE_ID is not set"
  exit 1
fi

if [ -z "$VERSION" ]; then
  echo "VERSION is not set"
  exit 1
fi

if [ -z "$SOURCE" ]; then
  SOURCE="./dist"
fi

if [ -z "$S3_KEY" ]; then
  S3_KEY="qmfe"
fi

if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

if [ -z "$WITH_DELETE" ]; then
  WITH_DELETE="false"
fi

if [ -z "$DRY_RUN" ]; then
  DRY_RUN="false"
fi

if [ -z "$CACHE_CONTROL" ]; then
  CACHE_CONTROL='public,max-age=31536000,s-maxage=2629800,immutable'
fi

echo "Running qmfe-to-aws with the following environment variables:"
echo "AWS_ACCESS_KEY_ID:      $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY:  $AWS_SECRET_ACCESS_KEY"
echo "AWS_BUCKET_NAME         $AWS_BUCKET_NAME"
echo "AWS_REGION              $AWS_REGION"
echo "QMFE_ID:                $QMFE_ID"
echo "VERSION:                $VERSION"
echo "SOURCE:                 $SOURCE"
echo "FILES:                  $FILES"
echo "S3_KEY:                 $S3_KEY"
echo "WITH_DELETE:            $WITH_DELETE"
echo "DRY_RUN:                $DRY_RUN"
echo "CACHE_CONTROL:          $CACHE_CONTROL"
echo ""

run() {
  [ ! -d "$SOURCE" ] && echo "ERROR: Directory $SOURCE does not exists." && exit 1

  aws --version

  aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile qcs-cdn
  aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile qcs-cdn

  echo ""
  echo "|-----------------------|"
  echo "| Deploying to CDN      |"
  echo "|-----------------------|"

  local dryrun
  [[ $DRY_RUN = "true" ]] && dryrun="--dryrun" || dryrun=""
  local delete_flag
  [[ $WITH_DELETE = "true" ]] && delete_flag="--delete" || delete_flag=""

  # sync individual files?
  if [[ -n "$FILES" ]]; then
    local -a files=()
    IFS=',' read -r -a files <<< "$FILES"
    for file in "${files[@]}"; do
      eval "aws $dryrun --profile qcs-cdn s3 cp $SOURCE/$file s3://$AWS_BUCKET_NAME/$S3_KEY/$QMFE_ID/$VERSION/ --region $AWS_REGION --cache-control $CACHE_CONTROL"
    done
  else
    # sync whole source folder
    eval "aws $dryrun --profile qcs-cdn s3 sync $SOURCE s3://$AWS_BUCKET_NAME/$S3_KEY/$QMFE_ID/$VERSION/ --region $AWS_REGION --exclude \"*.map\" $delete_flag --cache-control $CACHE_CONTROL"
  fi
  echo "Version $VERSION of $QMFE_ID is now published to s3://$AWS_BUCKET_NAME/$S3_KEY/$QMFE_ID/$VERSION/"
}

run "$@"
