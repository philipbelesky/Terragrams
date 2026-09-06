# Agent Instructions

This file tells you *how* to work. Always read the project `README.md` to understand *what* you are working on.

You should also read all other markdown files in the root directory and `docs` directory - e.g. documents like `PRD.md` or `TESTING.md` if they exist.

## Technology Stack (general)

- I prefer to use pnpm over npm. Only use npm when the current project does; default to pnpm for all other uses
- Pay attention to the node version defined in the package.json and/or in a `.node-version` or `.nvmrc` - if the shell is not aligned with this reference then don't try to workaround this - stop and notify me so it can be fixed.
- Note that the `README.md` will detail additional choices for this specific project
- Do not ever use `!important` when writing CSS

## Tooling

The repo's `.mcp.json` and plugin settings declare the MCP servers and plugins available to you; rely on that list rather than this file. Look up library and framework documentation through the configured docs server rather than from recall.

For Linear tickets and project context, use the `linear` CLI (see the `linear-cli` skill), not an MCP.

### Working Procedure

Before presenting web work as complete, run verification:

1. Format, lint, and typecheck the work
2. Run the tests and any validation you can (including browser-based testing)
3. Then present the work as complete

Refer to `README.md` for the specific commands to use

### Browser-Based Testing

You have access to `agent-browser` and a corresponding skill - it is an automation tool designed for agents. I expect you to use it to validate your work whenever you are changing anything on a frontend, or making a change that affects a frontend. At the least, check that any affected routes render without errors before presenting the work as complete. You can also use the Claude or Codex plugins for Chrome, Chrome Dev Tools MCP, Puppeteer MCP, etc if they offer you something `agent-browser` doesn't.

The applications you are testing will either have a dummy login or a login bypass method for local development. If you are blocked by a login, ping me, rather than skipping past it or doing a workaround.
