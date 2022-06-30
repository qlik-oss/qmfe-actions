import { templatePullRequestBody } from "../templating";
import { describe, test, expect } from "@jest/globals";

describe("Templating", () => {
  test("should template PR body", () => {
    const templateArgs = {
      namespace: "qmfe",
      qmfeId: "my-component",
      newVersion: "1.2.3",
      githubOrg: "my-org",
    };

    const res = templatePullRequestBody(templateArgs);
    expect(res).toBe(`Bumps \`my-component\` to \`1.2.3\`.

Refer to the release for more: <https://github.com/my-org/my-component/releases/tag/v1.2.3>
`);
  });

  test("should template PR body (with repo)", () => {
    const templateArgs = {
      namespace: "qmfe",
      qmfeId: "my-component",
      repo: "repo-name",
      newVersion: "1.2.3",
      githubOrg: "my-org",
    };

    const res = templatePullRequestBody(templateArgs);
    expect(res).toBe(`Bumps \`my-component\` to \`1.2.3\`.

Refer to the release for more: <https://github.com/my-org/repo-name/releases/tag/v1.2.3>
`);
  });
});
