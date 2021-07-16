import { readImportMap, updateImportMap } from "../import-map";
import fs from "fs";
import {
  describe,
  test,
  expect,
  beforeAll,
  beforeEach,
  afterAll,
} from "@jest/globals";

let wd;

const cdnBasePath = "https://cdn.qlik-stage.com";

describe("Update ImportMap", () => {
  beforeAll(() => {
    wd = process.cwd();
    const importMapFs = {
      imports: {
        "@qmfe/hub": "https://cdn.qlik-stage.com/qmfe/hub/2.0.231/qmfe-hub.js",
      },
    };
    fs.mkdirSync("./test-temp");
    process.chdir("./test-temp");
    fs.writeFileSync("./import-map.json", JSON.stringify(importMapFs));
  });

  afterAll(() => {
    fs.unlinkSync("./import-map.json");
    process.chdir(wd);
    fs.rmdirSync("./test-temp");
  });

  test("read import-map", () => {
    const importMap = readImportMap();

    expect(importMap.imports["@qmfe/hub"]).toEqual(
      "https://cdn.qlik-stage.com/qmfe/hub/2.0.231/qmfe-hub.js"
    );
  });

  describe("Add stuff to import-map", () => {
    let importMap;
    beforeEach(() => {
      importMap = readImportMap();
    });

    test("update existing qmfe id", () => {
      const updated = updateImportMap({
        cdnBasePath,
        importMap,
        namespace: "qmfe",
        qmfeId: "hub",
        version: "2.2.2",
        qmfeModules: [],
        hasSubmodules: false,
        dryRun: true,
      });
      const updatedJson = JSON.parse(updated);
      expect(updatedJson.imports["@qmfe/hub"]).toEqual(
        "https://cdn.qlik-stage.com/qmfe/hub/2.2.2/qmfe-hub.js"
      );
    });

    test("add new entry", () => {
      const updated = updateImportMap({
        cdnBasePath,
        importMap,
        namespace: "qlik-trial",
        qmfeId: "foo",
        version: "1.0.123",
        qmfeModules: null,
        hasSubmodules: false,
        dryRun: true,
      });
      const updatedJson = JSON.parse(updated);
      expect(updatedJson.imports["@qlik-trial/foo"]).toEqual(
        "https://cdn.qlik-stage.com/qmfe/foo/1.0.123/qlik-trial-foo.js"
      );
    });

    test("add new entry with submodules", () => {
      const updated = updateImportMap({
        cdnBasePath,
        importMap,
        namespace: "qlik-trial",
        qmfeId: "foo",
        version: "1.0.123",
        qmfeModules: null,
        hasSubmodules: true,
        dryRun: true,
      });
      const updatedJson = JSON.parse(updated);
      expect(updatedJson.imports["@qlik-trial/foo/"]).toEqual(
        "https://cdn.qlik-stage.com/qmfe/foo/1.0.123/"
      );
      expect(updatedJson.imports["@qlik-trial/foo"]).toBeUndefined();
    });

    test("add new entries with qmfeModules", () => {
      const updated = updateImportMap({
        cdnBasePath,
        importMap,
        namespace: "qlik-trial",
        qmfeId: "foo",
        version: "1.0.123",
        qmfeModules: ["bar", "baz"],
        hasSubmodules: false,
        dryRun: true,
      });
      const updatedJson = JSON.parse(updated);
      expect(updatedJson.imports["@qlik-trial/bar"]).toEqual(
        "https://cdn.qlik-stage.com/qmfe/foo/1.0.123/qlik-trial-bar.js"
      );
      expect(updatedJson.imports["@qlik-trial/baz"]).toEqual(
        "https://cdn.qlik-stage.com/qmfe/foo/1.0.123/qlik-trial-baz.js"
      );
    });

    test("verify that import-map.json is written", () => {
      updateImportMap({
        cdnBasePath,
        importMap,
        namespace: "qmfe",
        qmfeId: "foo",
        version: "1.0.123",
        qmfeModules: null,
        hasSubmodules: false,
        dryRun: false,
      });
      const updatedJson = readImportMap();
      expect(updatedJson.imports["@qmfe/foo"]).toEqual(
        "https://cdn.qlik-stage.com/qmfe/foo/1.0.123/qmfe-foo.js"
      );
      expect(updatedJson.imports["@qlik-trial/foo"]).toBeUndefined();
    });
  });
});