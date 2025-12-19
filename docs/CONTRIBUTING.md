# Contributing to Rho Aias

First off, thank you for considering contributing. This project is a mission-driven effort to build tools for cognitive sovereignty, and every contribution is valuable.

This document provides a set of guidelines to ensure the project's codebase remains clean, consistent, and maintainable. Adhering to these standards respects the time and effort of all developers involved.

## Table of Contents
1. [Code of Conduct](#code-of-conduct)
2. [Development Philosophy](#development-philosophy)
3. [Git Workflow](#git-workflow)
4. [Coding Style & Conventions](#coding-style--conventions)
5. [Commit Message Guidelines](#commit-message-guidelines)
6. [Submitting Changes](#submitting-changes)

---

## 1. Code of Conduct

This project and everyone participating in it is governed by a simple rule: be constructive and respectful. The goal is to build a high-quality product through focused, collaborative effort.

## 2. Development Philosophy

*   **Clarity over cleverness:** Code should be easy to read and understand. A slightly more verbose but obvious implementation is always preferable to a "clever" one-liner that requires a comment to explain.
*   **Write for the long term:** Assume that the code you write today will need to be debugged or refactored by someone else (or your future self) a year from now. Add comments where the logic is complex.
*   **Follow the architecture:** All new code must respect the architectural principles laid out in `docs/ARCHITECTURE.md`. Specifically, maintain the strict separation between the Adapter, the Engine, and the UI.

## 3. Git Workflow

This project uses a simple feature-branch workflow. The `main` branch is considered sacred and must always be in a stable, shippable state.

1.  **Branching:**
    *   All new work (features, bug fixes, documentation) **must** be done on a separate branch.
    *   Branch names should be descriptive and follow the `type/short-description` convention.
        *   **Feature:** `feat/add-claude-adapter`
        *   **Bugfix:** `fix/aura-tooltip-rendering`
        *   **Documentation:** `docs/update-readme`
        *   **Refactor:** `refactor/optimize-entropy-calculation`

2.  **The `main` Branch:**
    *   Direct pushes to the `main` branch are strictly forbidden.
    *   Changes are merged into `main` only through Pull Requests (PRs).

## 4. Coding Style & Conventions

To maintain a consistent and readable codebase, we enforce the following standards automatically.

*   **Linter:** [ESLint](https://eslint.org/) with the [Airbnb Style Guide](https://github.com/airbnb/javascript) is configured for this project. It is the single source of truth for code style.
*   **Formatter:** [Prettier](https://prettier.io/) is used for automatic code formatting. It handles all stylistic concerns like indentation, line breaks, and spacing.
*   **Enforcement:** A pre-commit hook is set up to automatically run Prettier and ESLint on any changed files before a commit is allowed. This ensures that no poorly formatted or stylistically inconsistent code ever enters the repository.

#### Key Conventions:
*   **Language:** Use modern JavaScript (ES6+), including `const`/`let`, arrow functions, and modules (`import`/`export`).
- **Naming:**
    - Functions & variables: camelCase
    - Classes & Components: PascalCase
    - Constants: UPPER_SKEWER_CASE
    - Files: kebab-case.js (e.g., core-engine.js). This is the enforced standard for the project.
*   **Asynchronicity:** Use `async/await` for all asynchronous operations. Avoid raw Promises and callbacks where possible.

## 5. Commit Message Guidelines

Clear and descriptive commit messages are essential for understanding the project's history. This project adheres to the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.

**Format:**
```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

**Common Types:**

*   `feat`: A new feature for the user.
*   `fix`: A bug fix for the user.
*   `chore`: Changes to the build process or auxiliary tools. No production code changes.
*   `docs`: Documentation only changes.
*   `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc.).
*   `refactor`: A code change that neither fixes a bug nor adds a feature.
*   `perf`: A code change that improves performance.
*   `test`: Adding missing tests or correcting existing tests.

**Examples:**

*   **Good:** `feat(ui): add on-hover diagnostic tooltip to aura`
*   **Good:** `fix(adapter): correct CSS selector for OpenAI message bubbles`
*   **Good:**
    ```
    refactor(engine): optimize entropy calculation algorithm

    The previous O(n^2) implementation was causing performance degradation
    on long conversations. Replaced with a more efficient O(n) approach
    using a sliding window and a Map for keyword counts.
    ```
*   **Bad:** `updated files`
*   **Bad:** `bug fix`

## 6. Submitting Changes

1.  Create your feature branch from the latest `main`. (`git checkout -b feat/my-new-feature`)
2.  Make your changes. Ensure all code passes the linter. (`npm run lint`)
3.  Add and commit your changes using the Conventional Commits format.
4.  Push your branch to the remote repository. (`git push origin feat/my-new-feature`)
5.  Open a Pull Request (PR) against the `main` branch.
6.  The PR title should be a clear, high-level summary of the changes.
7.  In the PR description, briefly explain the "why" behind your changes and reference any relevant issues.
8.  The PR will be reviewed, and once approved, it will be squashed and merged into `main`.

