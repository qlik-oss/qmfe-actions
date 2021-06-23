# AWS S3 Docker action

Action using the [AWS-CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) to upload an `import-map.json` to an AWS S3-bucket

## Inputs

| Key                     | Description                                                                    | Required  | Default                         |
| ----------------------- | ------------------------------------------------------------------------------ | --------- | ------------------------------- |
| `aws-bucket-name`       | The bucket to upload to                                                        | **TRUE**  | **SECRET**                      |
| `aws-access-key-id`     | The AWS Access Key                                                             | **TRUE**  | **SECRET**                      |
| `aws-secret-access-key` | The AWS secret access key                                                      | **TRUE**  | **SECRET**                      |
| `aws-distribution-id`   | AWS Cloudfront distribution id. Used for invalidating the cache for import-map | **TRUE**  | **SECRET**                      |
| `import-map-url`        | Url to the aws cloudfront location hosting the import-map                      | **TRUE**  | **SECRET**                      |
| `s3-key`                | S3 key (folder) where import-map should be uploaded to                         | **FALSE** | 'qmfe'                          |
| `exclude`               | import-map entries to exclude in a comma separated string                      | **TRUE**  | ''                              |
| `transform`             | Transform regex to apply on the full import map using the sed command          | **FALSE** | ''                              |
| `aws-region`            | AWS Region of the S3 bucket                                                    | **FALSE** | 'us-east-1'                     |
| `dry-run`               | Run action, but don't do the actual upload                                     | **FALSE** | 'false'                         |
| `cache-control`         | Set cache-control header                                                       | **FALSE** | 'public,max-age=5,s-maxage=300' |
| `file-name`             | File name of import-map                                                        | **FALSE** | 'import-map.json'               |

## Example usage

Create a workflow `.github/workflows` folder.

```yaml
name: S3 Sync
on: push
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Upload qmfe package
        uses: qlik-oss/qmfe-actions/import-map-to-aws@master
        with:
          aws-bucket-name: s3-bucket-name.host.com
          aws-access-key-id: ${{ secrets.MY_SECRET }}
          aws-secret-access-key: ${{ secrets.MY_OTHER_SECRET }}
          aws-distribution-id: ${{ secrets.MY_THIRD_SECRET }}
          import-map-url: https://thecdn.com
```
