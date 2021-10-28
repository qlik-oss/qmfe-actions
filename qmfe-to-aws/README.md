# AWS S3 Docker action

Action using the [AWS-CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) to sync a qmfe package to an S3 bucket.

The files in the `source` directory will end up in `s3://<aws-bucket-name>/<s3-key>/<qmfe-id>/<version>/`

## Inputs

| Key                     | Description                                               | Required  | Default     |
| ----------------------- | --------------------------------------------------------- | --------- | ----------- |
| `aws-bucket-name`       | The bucket to sync                                        | **TRUE**  |             |
| `aws-access-key-id`     | The AWS Access Key                                        | **TRUE**  |             |
| `aws-secret-access-key` | The AWS secret access key                                 | **TRUE**  |             |
| `qmfe-id`               | The name id of QMFE package, e.g. "hub" or "navigation"   | **TRUE**  |             |
| `version`               | The version of the qmfe package                           | **TRUE**  |             |
| `source`                | Your local file path that you wish to upload to S3        | **TRUE**  |             |
| `files`                 | Comma separated file list to upload, empty="whole folder" | **FALSE** |             |
| `s3-key`                | S3 folder path in bucket                                  | **TRUE**  | 'qmfe'      |
| `aws-region`            | The region of the bucket                                  | **FALSE** | 'us-east-1' |
| `dry-run`               | Run action, but don't do the actual upload                | **FALSE** | 'false'     |
| `with-delete`           | If you want to use the [_--delete_ flag] in sync call     | **FALSE** | 'true'      |
| `include-sourcemaps`    | also uploads sourcemaps to S3 bucket                      | **FALSE** | 'false'     |
| `cache-control`         | Set cache-control header                                  | **FALSE** | `*`         |

`*`: cache-control defaults to `public,max-age=31536000,s-maxage=2629800,immutable`

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
        uses: qlik-oss/qmfe-to-aws@v1
        with:
          aws-bucket-name: bucket.domain.com
          aws-access-key-id: ${{ secrets.MY_SECRET }}
          aws-secret-access-key: ${{ secrets.MY_OTHER_SECRET }}
          qmfe-id: "my-microfrontend"
          version: "1.2.3"
          source: "./dist"
```
