# Merge Branch action

Merges a source branch to a target branch in the current repository.

## Inputs

| Key       | Description                      | Required | Default |
| --------- | -------------------------------- | -------- | ------- |
| `source`  | Source branch to merge from      | **TRUE** |         |
| `target`  | Target branch to merge to        | **TRUE** |         |
| `ff-only` | Do merge with ff-only            | **TRUE** |         |
| `token`   | Github token with access to repo | **TRUE** |         |

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
        uses: qlik-oss/qmfe-actions/merge-branch@v1
        with:
          source: main
          target: deploy
          ff-only: "false"
          token: ${{ github.token }}
```
