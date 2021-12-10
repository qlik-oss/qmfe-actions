import * as core from "@actions/core";
import { exec } from "@actions/exec";
import { Octokit } from "@octokit/rest";
import { templatePullRequestBody } from "./templating";
import { updateImportMap, readImportMap } from "./import-map";

type Options = {
  cdnBasePath: string;
  qmfeModules: string[] | null;
  namespace: string;
  qmfeId: string;
  githubTeam: string;
  githubToken: string;
  githubOrg: string;
  githubRepo: string;
  gitUsername?: string;
  gitEmail?: string;
  version: string;
  hasSubmodules: boolean;
  dryRun: boolean;
};

export class GH {
  private octokit: Octokit;

  constructor(public opts: Options) {
    this.octokit = new Octokit({
      auth: opts.githubToken,
      userAgent: "qlik-oss/qmfe-actions",
    });
  }

  // Change the GitHub user if desired
  // User information comes from action inputs
  async configureGitUser() {
    const { gitUsername, gitEmail } = this.opts;
    if (gitUsername && gitEmail) {
      await exec(`git config user.name "${gitUsername}"`);
      await exec(`git config user.email "${gitEmail}"`);
    }
  }

  async checkoutBranch(branchName: string) {
    try {
      const code = await exec(`git checkout -b "${branchName}"`);
      // In case the branch already exists
      if (code !== 0) {
        await exec(`git checkout "${branchName}"`);
      }
      // Ensure workspace is fresh
      await exec(`git fetch`);
      await exec(`git reset --hard origin/main`);
    } catch (err) {
      core.info(`Error creating new branch: ${err}`);
    }
  }

  async commitChanges(commitMessage: string, branchName: string) {
    await exec(`git add import-map.json`);
    await exec(`git commit -m "${commitMessage}"`);
    await exec(`git push -u origin "${branchName}" --force`);
  }

  async closeOlderPullRequests(
    githubOrg: string,
    githubRepo: string,
    currentPRTitle: string
  ) {
    const { data: openPRs } = await this.octokit.pulls.list({
      owner: githubOrg,
      repo: githubRepo,
      state: "open",
    });

    const regex = new RegExp(
      `chore\\(release\\): update @${this.opts.namespace}/${this.opts.qmfeId} to \\d\+\.\\d\+\.\\d\+$`
    );
    const targets = openPRs
      .map(({ title, head }) => {
        // Do not cleanup the branch/PR that is doing the same update.
        // It will be force pushed anyways.
        if (title.match(regex) && title !== currentPRTitle) {
          core.info(`Matched on ${title}`);
          return exec(`git push origin --delete ${head.ref}`).catch((err) => {
            core.info(`Could not delete branch '${head.ref}': ${err}`);
          });
        }
      })
      .filter(Boolean);

    try {
      await Promise.all(targets);
    } catch (err) {
      core.info(JSON.stringify(err));
    }
  }

  async createPullRequest() {
    const {
      cdnBasePath,
      qmfeModules,
      qmfeId,
      namespace,
      version,
      hasSubmodules,
      githubToken,
      githubTeam,
      githubOrg,
      githubRepo,
      dryRun,
    } = this.opts;
    let updatedImportMap: string;
    const componentName = `@${namespace}/${qmfeId}`;
    const importMap = readImportMap();
    const HEAD_BRANCH = `${componentName}-integration-${version}`;
    const GIT_MSG = `chore(release): update ${componentName} to ${version}`;
    const PR_BODY = templatePullRequestBody({
      qmfeId,
      newVersion: version,
      githubOrg,
    });

    if (dryRun) {
      updatedImportMap = updateImportMap({
        cdnBasePath,
        importMap,
        namespace,
        qmfeId,
        version,
        qmfeModules,
        hasSubmodules,
        dryRun,
      });
      core.info("[dryrun] import-map.json updated");
      core.info(updatedImportMap);
      return;
    }

    await this.configureGitUser();
    await this.checkoutBranch(HEAD_BRANCH);

    updatedImportMap = updateImportMap({
      cdnBasePath,
      importMap,
      namespace,
      qmfeId,
      version,
      qmfeModules,
      hasSubmodules,
    });

    core.info("import-map.json updated");
    core.info(updatedImportMap);

    await this.commitChanges(GIT_MSG, HEAD_BRANCH);

    try {
      await this.closeOlderPullRequests(githubOrg, githubRepo, GIT_MSG);

      // CLI Needs it to be set, being explicity here but this can probably be omitted
      // since it reads from the env anyways
      // DO NOT LOG THIS. EVER.
      process.env.GITHUB_TOKEN = githubToken;

      const createPullRequestCommand = `gh pr create \
      --title "${GIT_MSG}" \
      --body "${PR_BODY}" \
      --repo="${githubOrg}/${githubRepo}" \
      --reviewer "${githubTeam}" \
      --base "main" \
      --head "${HEAD_BRANCH}"`;

      // This needs a separate call to add reviewers
      // this.octokit.pulls.create({
      //   owner: githubOrg,
      //   repo: githubRepo,
      //   title: GIT_MSG,
      //   head: HEAD_BRANCH,
      //   base: "main",
      // })

      core.info(`Executing: ${createPullRequestCommand}`);
      await exec(createPullRequestCommand);
    } catch (err) {
      core.error(`Could not create PR. See output.`);
    } finally {
      process.env.GITHUB_TOKEN = undefined;
    }
  }
}
