# checksum-file-to-aws

Computes an md5 checksum on a given file and uploads an empty file with the checksum as name to a AWS S3 bucket location

## Inputs

| Key                     | Description                                | Required  | Default     |
| ----------------------- | ------------------------------------------ | --------- | ----------- |
| `aws-bucket`            | The bucket to upload to                    | **TRUE**  | **SECRET**  |
| `aws-access-key-id`     | The AWS Access Key                         | **TRUE**  | **SECRET**  |
| `aws-secret-access-key` | The AWS secret access key                  | **TRUE**  | **SECRET**  |
| `file`                  | path to file to use                        | **TRUE**  | **SECRET**  |
| `aws-region`            | AWS Region of the S3 bucket                | **FALSE** | 'us-east-1' |
| `dry-run`               | Run action, but don't do the actual upload | **FALSE** | 'false'     |

## Example usage

Create a workflow `.github/workflows` folder.

```yaml
name: name
on: push

jobs:
  upload-checksum-file:
    runs-on: ubuntu-latest
    steps:
      - name: Uploads checksum of file to AWS
        uses: qlik-oss/checksum-file-to-aws@v1
        with:
          aws-bucket: s3://bucket.host.com/path/to/folder
          aws-access-key-id: ${{ secrets.MY_SECRET }}
          aws-secret-access-key: ${{ secrets.MY_OTHER_SECRET }}
          file: .thefiletouse.zyx
```
