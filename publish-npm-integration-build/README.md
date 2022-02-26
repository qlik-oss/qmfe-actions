# Publish NPM integration build

Publishes an integration (pre-release) npm package to the configured package registry.

## Inputs

| Key             | Description                                                                                               | Required  | Default   |
| --------------- | --------------------------------------------------------------------------------------------------------- | --------- | --------- |
| `dist-folder`   | Path to the folder to publish                                                                             | **TRUE**  |           |
| `build-script`  | The full command to build the projects NPM package.                                                       | **FALSE** | `""`      |
| `enforce-types` | Whether to enforce the inclusion of type declarations in the package                                      | **FALSE** | `"true"`  |
| `include-types` | Makes the step fail if no type declarations are found in the package. **Deprecated**: use `enforce-types` | **FALSE** | `"true"`  |
| `dry-run`       | Skips the actual publishing steps, mainly for testing the action                                          | **FALSE** | `"false"` |

## Example usage

Add this to your workflow that runs on PRs.

```yaml
jobs:
  ...

  publish-integration:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: "16"
          cache: npm
      - run: npm install
      - run: npm run build-npm
      - name: Publish integration build
        uses: qlik-oss/publish-npm-integration-build@v1
        with:
          dist-folder: "./dist-types"
```
