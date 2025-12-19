# Contributing to Rho Aias

First off, thank you for considering contributing.

This document provides a set of guidelines to ensure the project's codebase remains clean, consistent, and maintainable. Adhering to these standards respects the time and effort of all developers involved.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Development Philosophy](#development-philosophy)
3. [Git Workflow](#git-workflow)
4. [Coding Style & Conventions](#coding-style--conventions)
5. [Commit Message Guidelines](#commit-message-guidelines)
6. [Submitting Changes](#submitting-changes)

---

## 1. Core Protocols

- **Architecture First:** Before writing code, internalize `docs/ARCHITECTURE.md`. We enforce a strict separation between **Adapter** (DOM), **Engine** (Logic), and **UI** (Render).
- **TypeScript Only:** All source code in `src/` must be TypeScript. No `.js` files are permitted.
- **Docker Mandatory:** Development must occur within the provided Dev Container to ensure a reproducible environment.

## 2. Development Workflow

### Setup

1.  Open the project in VS Code with the **Dev Containers** extension.
2.  Run `npm ci` to install dependencies (uses strict lockfile).

### The Two Modes

- **UI/Logic Work:** Use `npm run dev`. This opens the **Sandbox** (Hot-Reload) for fast iteration on the Engine and UI components.
- **Integration Work:** Use `npm run build -- --watch`. This compiles the extension to `dist/` for manual loading in Chrome.

## 3. Coding Standards

- **Linter:** ESLint (Airbnb Style). Run `npm run lint`.
- **Formatter:** Prettier. Run `npm run format`.
- **Type Safety:** `noImplicitAny` is on. Define interfaces in `src/shared/types.ts`.
- **No Direct DOM Access:** The _only_ module allowed to touch `document` is the **Site Adapter**. The Engine and UI must remain pure/declarative.

## 4. Git & Commits

We use the **Feature Branch** workflow and **Conventional Commits**.

1.  **Branching:** Create branches from `main`. Naming convention: `type/short-description` (e.g., `feat/add-claude-adapter`, `fix/aura-z-index`).
2.  **Commit Messages:** Must follow the [Conventional Commits](https://www.conventionalcommits.org/) format:
    - `feat`: New feature
    - `fix`: Bug fix
    - `refactor`: Code change that neither fixes a bug nor adds a feature
    - `docs`: Documentation only
    - `chore`: Build/Tooling changes
3.  **Pull Requests:**
    - Push to your branch.
    - Open a PR against `main`.
    - Ensure CI checks (Lint/Test/Build) pass.
    - Squash and merge upon approval.

---
