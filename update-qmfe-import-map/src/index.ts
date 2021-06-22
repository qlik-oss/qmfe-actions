import * as core from "@actions/core";
import * as _ from "dotenv"; // Needed for process.env
import { normalizeBasePath, parseModulesInput, readVersionInput } from "./util";
import { GH } from "./gh";

async function run(): Promise<void> {
  try {
    const cdnBasePath = normalizeBasePath(core.getInput("cdn-base-path"));
    const dryRun = core.getInput("dry-run") === "true";
    const namespace = core.getInput("namespace") || "qmfe";
    const qmfeId = core.getInput("qmfe-id");
    const githubTeam = core.getInput("github-team");
    const githubToken = core.getInput("github-token");
    const githubOrg = core.getInput("github-org");
    const githubRepo = core.getInput("github-repo");
    const gitUsername: string | undefined = core.getInput("git-username");
    const gitEmail: string | undefined = core.getInput("git-email");
    const version = readVersionInput(core.getInput("version"));
    const qmfeModules = parseModulesInput(
      core.getInput("qmfe-components") || core.getInput("qmfe-modules")
    );

    const hasSubmodules = core.getInput("qmfe-submodules") === "true";

    const gh = new GH({
      cdnBasePath,
      qmfeModules,
      namespace,
      qmfeId,
      githubTeam,
      githubToken,
      githubOrg,
      githubRepo,
      gitUsername,
      gitEmail,
      version,
      hasSubmodules,
      dryRun,
    });

    await gh.createPullRequest();
    core.info(dryRun ? "[Dry run] Success!" : "Success!");
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
