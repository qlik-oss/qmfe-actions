import { readFileSync, writeFileSync } from "fs";

export type ImportMap = { imports: Record<string, string> };

type UpdateImportMapArgs = {
  cdnBasePath: string;
  importMap: ImportMap;
  qmfeNamespace: string;
  qmfeId: string;
  version: string;
  qmfeModules: string[] | null;
  hasSubmodules?: boolean;
  dryRun?: boolean;
};

export function readImportMap(): ImportMap {
  return JSON.parse(readFileSync("import-map.json", "utf8"));
}

export function formatImportMap(importMapString: string) {
  return importMapString.replace(/,\n+/g, ",\n\n");
}

export function updateImportMap({
  cdnBasePath,
  importMap,
  qmfeNamespace,
  qmfeId,
  version,
  qmfeModules = null,
  hasSubmodules = false,
  dryRun = false,
}: UpdateImportMapArgs): string {
  if (qmfeModules && qmfeModules.length) {
    for (const componentId of qmfeModules) {
      const newUrl = `${cdnBasePath}/qmfe/${qmfeId}/${version}/${componentId}.js`;
      importMap.imports[`@${qmfeNamespace}/${componentId}`] = newUrl;
    }
  } else if (hasSubmodules) {
    const newUrl = `${cdnBasePath}/qmfe/${qmfeId}/${version}/`;
    importMap.imports[`@${qmfeNamespace}/${qmfeId}/`] = newUrl;
  } else {
    const newUrl = `${cdnBasePath}/qmfe/${qmfeId}/${version}/${qmfeNamespace}-${qmfeId}.js`;
    importMap.imports[`@${qmfeNamespace}/${qmfeId}`] = newUrl;
  }

  const importMapString = `${JSON.stringify(importMap, null, 2)}\n`;
  let updatedImportMap = formatImportMap(importMapString);
  if (!dryRun) {
    writeFileSync("import-map.json", updatedImportMap);
  }
  return updatedImportMap;
}
