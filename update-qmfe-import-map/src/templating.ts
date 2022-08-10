import * as core from "@actions/core";

type PRBodyTemplateArgs = {
  newVersion: string;
  qmfeId: string;
  repo?: string | undefined;
  githubOrg: string;
};

// NOTE(bgd): Inlined the template because of issues with paths
// when using the action.
const templatePRBody = (it: PRBodyTemplateArgs): string => {
  return `Bumps \`${it.qmfeId}\` to \`${it.newVersion}\`.

Refer to the release for more: <https://github.com/${it.githubOrg}/${
    it.repo || it.qmfeId
  }/releases/tag/v${it.newVersion}>
`;
};

export function templatePullRequestBody(
  templateArgs: PRBodyTemplateArgs
): string {
  try {
    const resultText = templatePRBody(templateArgs);
    return resultText;
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    core.error(`Error when creating PR body from template: ${message}`);
    throw error;
  }
}
