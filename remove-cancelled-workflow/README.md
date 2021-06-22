# Remove last cancelled workflow

Action that removes the last cancelled workflow in a repository's action list.

## Inputs

| Key             | Description                               | Required |
| --------------- | ----------------------------------------- | -------- |
| `REPOSITORY`    | Repository containing workflow            | **TRUE** |
| `WORKFLOW_NAME` | Name of workflow that should be cancelled | **TRUE** |
| `GITHUB_TOKEN`  | Github token with access to the repo      | **TRUE** |

## Example usage

Create a workflow `.github/workflows` folder.

```yaml
name: S3 Sync
on [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Clean up cancelled
        uses: qlik-oss/qmfe-actions/remove-cancelled-workflow
        with:
          repository: my-repo
          workflow-name: my-workflow
          github-token: ${{ github.token }}
```
