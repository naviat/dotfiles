# Project notes for agents

## What this is

<one or two lines: what the project does and who uses it>

## Commands

- Build/test/lint: `<command>` (the Makefile or package scripts are authoritative)

## Rules

- Never print or commit secrets, credentials, account IDs or tokens.
- Make the smallest change that solves the problem, then run the checks above.
- Explain a change by pointing at the exact file and line so a human can verify it.

## Deliberate decisions

<list choices that look wrong but are intentional, so agents do not revert them>

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
