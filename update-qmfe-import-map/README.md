# update-qmfe-import-map

This action performs an update to bump a component in the `import-map.json` file which serves as a manifest for micro-frontends.

> **Note** for this action to work correctly, `import-map.json` needs to be in the current working directory.

## Developing

To update the action, from this folder, edit the TS code and run `npm run all` and check in the changes.
Since GitHub Actions does not run TypeScript natively, it needs to have the built artifacts checked in.
