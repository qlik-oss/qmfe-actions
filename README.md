# qmfe-actions

> **Warning** DEPRECATED: Since GitHub Actions can reference private workflows, we've decided to move these to our private org.

This repository contains custom actions used in the micro-frontend world.

| Actions                                                                    | Description                                                          |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| [checksum-file-to-aws](./checksum-file-to-aws/README.md)                   | Calculates a checksum on a given file and uploads it to an S3 bucket |
| [import-map-to-aws](./import-map-to-aws/README.md)                         | Uploads an import-map.json to an S3 bucket with some checks          |
| [publish-npm-integration-build](./publish-npm-integration-build/README.md) | Publish npm integration version                                      |
| [qmfe-to-aws](./qmfe-to-aws/README.md)                                     | Uploads a qmfe build to an S3 bucket                                 |
| [remove-cancelled-workflow](./remove-cancelled-workflow/README.md)         | Removes cancelled workflows                                          |
| [update-qmfe-import-map](./update-qmfe-import-map/README.md)               | Updates a certain entry in the import-map                            |
