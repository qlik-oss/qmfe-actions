import * as core from "@actions/core";
import { readFileSync, writeFileSync } from "fs";

type ImportMap = { imports: Record<string, string> };

type UpdateImportMapArgs = {
  cdnBasePath: string;
  importMap: ImportMap;
  namespace: string;
  qmfeId: string;
  version: string;
  qmfeModules: string[] | null;
  hasSubmodules?: boolean;
  dryRun?: boolean;
};

export function readImportMap(): ImportMap {
  return JSON.parse(readFileSync("import-map.json", "utf8"));
}

export function updateImportMap({
  cdnBasePath,
  importMap,
  namespace,
  qmfeId,
  version,
  qmfeModules = null,
  hasSubmodules = false,
  dryRun = false,
}: UpdateImportMapArgs) {
  if (qmfeModules) {
    for (const componentId of qmfeModules) {
      const newUrl = `${cdnBasePath}/qmfe/${qmfeId}/${version}/${namespace}-${componentId}.js`;
      importMap.imports[`@${namespace}/${componentId}`] = newUrl;
    }
  } else {
    const newUrl = `${cdnBasePath}/qmfe/${qmfeId}/${version}/${namespace}-${qmfeId}.js`;
    importMap.imports[`@${namespace}/${qmfeId}`] = newUrl;
    if (hasSubmodules) {
      const newUrl = `${cdnBasePath}/qmfe/${qmfeId}/${version}/`;
      importMap.imports[`@${namespace}/${qmfeId}/`] = newUrl;
    }
  }

  const updatedImportMap = `${JSON.stringify(importMap, null, 2)}\n`;
  if (!dryRun) {
    writeFileSync("import-map.json", updatedImportMap);
  }

  core.info("import-map.json updated");
  core.info(updatedImportMap);
}
