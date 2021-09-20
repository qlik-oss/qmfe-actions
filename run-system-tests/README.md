# Run system tests

Action to run the system tests with certain inputs (suite, import-map-overrides).

## Inputs

| Key                     | Description                                                                    | Required  | Default                         |
| ----------------------- | ------------------------------------------------------------------------------ | --------- | ------------------------------- |
| `suite`                 | The test suite to run                                                          | **FALSE** | 'qmfe'                          |
| `import-map-overrides`  | Import-map overrides to use e.g as a JSON string or URL to import-map          | **FALSE** | Defaults to no overrides        |
| `docker-image`          | The docker image to use                                                        | **TRUE**  | ''                              |
| `docker-username`       | The docker user name                                                           | **TRUE**  | ''                              |
| `docker-password`       | The docker password                                                            | **TRUE**  | ''                              |
| `grid-url`              | The Zalenium Grid to use                                                       | **FALSE** | Defaults to no grid             |
| `parallel-execution`    | Number of webdrivers to run in parallel                                        | **FALSE** | Defaults to 1                   |
| `base-url`              | URL to QSE tenant                                                              | **TRUE**  | ''                              |
| `auth-url`              | URL to auth provider                                                           | **FALSE** | **SECRET**                      |

## Example usage

Create a workflow `.github/workflows` folder.

```yaml
name: Run system tests
on: pull-request
  system-test:
    runs-on: ubuntu-latest
    steps:
      - uses: qlik-oss/qmfe-actions/run-system-tests@v1
        with:
          docker-image: registry/org/image:latest
          docker-username: my-docker-username
          docker-password: my-docker-password
          grid-url: http://grid-to-use
          parallel-execution: 6
          base-url: https://qse-tenant.com
          suite: qmfe
          import-map-overrides: "{\"@qmfe/qmfeId\":\"https://cdn-url.com/qmfe/qmfeId/version/qmfeId.js\"}"
```