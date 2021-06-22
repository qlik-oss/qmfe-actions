import * as core from "@actions/core";

export const parseModulesInput = (qmfeModules: string): string[] | null => {
  try {
    core.info(`Parsing: ${qmfeModules}`);
    return JSON.parse(qmfeModules) as string[];
  } catch (err) {
    throw new Error(`Error while parse module list: ${err}`);
  }
};

/**
 * To ensure it does not contain a trailing slash it gets removed
 * first thing when the action runs. That way we can be sure we
 * have a URL not containing a trailing slash.
 *
 * @param basePath some URL
 * @returns some URL not containing a trailing slash
 */
export const normalizeBasePath = (basePath: string): string => {
  if (basePath.endsWith("/")) {
    return basePath.substring(0, basePath.length - 1);
  }
  return basePath;
};

export const readVersionInput = (version: string): string => {
  if (version.startsWith("v")) {
    version = version.substring(1);
  }
  return version;
};
