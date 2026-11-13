# Issue tracker: GitHub

Issues and specs live in GitHub Issues for `the-kbA-team/cake2_app_version`.
Use `gh` for tracker operations. Run
`export GH_REPO=the-kbA-team/cake2_app_version` to select this repository even
when multiple remotes exist.

## Conventions

- Create an issue: `gh issue create --title "..." --body "..."`
- Read an issue: `gh issue view <number> --json number,title,body,labels,comments`
- List issues: `gh issue list --state open --json number,title,body,labels,comments`,
  adding appropriate `--label` and `--state` filters.
- Add a sub-issue: `gh issue create --parent <parent> ...` or
  `gh issue edit <parent> --add-sub-issue <child>` with gh 2.94 or newer.
  If sub-issues are unavailable, add `Part of #<parent>` to the child.
- Comment: `gh issue comment <number> --body "..."`
- Apply or remove labels: `gh issue edit <number> --add-label "..."` or
  `--remove-label "..."`
- Close: `gh issue close <number> --comment "..."`

When a skill says to publish to the issue tracker, create a GitHub issue. When
it says to fetch a ticket, read the issue.

## Pull requests as a triage surface

**PRs as a request surface: no.** Set this to `yes` if external pull requests
should enter the triage queue.

If enabled, use `gh pr view`, `gh pr list`, `gh pr comment`, `gh pr edit`, and
`gh pr close` for the corresponding triage operations. GitHub shares the issue
and pull request number space: resolve ambiguous numbers with `gh pr view` and
then `gh issue view`.

## Wayfinding

- Create a map issue labelled `wayfinder:map`, containing Notes, Decisions-so-far
  and Fog. Create missing wayfinder labels in GitHub when needed. Add child
  issues as sub-issues, or use a task list in the map and `Part of #<map>` in
  each child if sub-issues are unavailable.
- Label child tickets `wayfinder:research`, `wayfinder:prototype`,
  `wayfinder:grilling`, or `wayfinder:task`; assign a ticket when claimed.
- Use GitHub issue dependencies for blockers:
  `gh api --method POST repos/the-kbA-team/cake2_app_version/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`.
  The blocker ID is the numeric database ID from
  `gh api repos/the-kbA-team/cake2_app_version/issues/<number> --jq .id`, not
  the issue number. If dependencies are unavailable, add
  `Blocked by: #<number>, ...` to the child.
- The frontier consists of open, unassigned children without open blockers;
  select the first in map order. Claim it with
  `gh issue edit <number> --add-assignee @me`.
- Resolve a ticket by commenting the answer, closing it, and adding a summary
  and link to the map's Decisions-so-far.
