# Service B - Spring Boot with Semantic Release & Maven

A minimalistic Spring Boot demo application that demonstrates automated semantic versioning using semantic-release with a Maven-based project.

## Overview

This project showcases how to integrate semantic-release with a Java Spring Boot application to automate version management and release processes. It provides a simple REST API service running on port 8081.

## Semantic Release Integration

This project uses [semantic-release](https://github.com/semantic-release/semantic-release) to automate version management and package publishing. Semantic-release determines the next version number, generates release notes, and publishes the package automatically by analyzing commit messages.

### How it works

1. Commit messages in this project follow the [Conventional Commits](https://www.conventionalcommits.org/) specification
2. Based on these commit messages, semantic-release automatically determines the next version number using semantic versioning rules:
   - `fix:` commits trigger a PATCH release (1.0.0 → 1.0.1)
   - `feat:` commits trigger a MINOR release (1.0.0 → 1.1.0)
   - `feat!:` or `fix!:` commits (or commits with BREAKING CHANGE in the footer) trigger a MAJOR release (1.0.0 → 2.0.0)

### Workflow

When a release is triggered:

1. semantic-release analyzes commits since the last release to determine the new version number
2. The `release.sh` script is executed with the new version number
3. Maven builds the JAR with the updated version
4. The JAR artifact is copied to the `release` directory
5. The artifact is deployed to GitHub Packages
6. A GitHub Release is created with the JAR attached as an asset

### Configuration

The semantic-release configuration is defined in `.releaserc` and includes:
- Branch configuration (releases from `main`, `beta` and `develop` branches)
- Plugin configuration for analyzing commits, generating release notes, and publishing to GitHub
- The execution of `release.sh` to build and package the Java application

## Generated Artifacts

Each release produces the following artifacts:

1. **JAR file**: `service-b-x.y.z.jar` in the `release` directory
   - This contains the compiled Spring Boot application
   - Also uploaded as an asset to the GitHub Release

2. **Maven package in GitHub Packages**:
   - The JAR is also deployed to GitHub Packages for use as a dependency in other projects
   - Repository URL: `https://maven.pkg.github.com/emboss/service-b`

## Husky Integration

This project uses [Husky](https://typicode.github.io/husky/) to enforce commit message conventions.

### Purpose of Husky

Husky enables Git hooks within the project to enforce standards and run scripts at specific points in the Git workflow.

### How Husky is configured

The project includes a commit-msg hook that:
- Validates that commit messages follow the Conventional Commits format
- Ensures all commits can be properly analyzed by semantic-release
- Enforces the pattern: `type(scope): message` where type is one of:
  - feat, fix, chore, docs, test, style, refactor, perf, build, ci, revert, release
- Rejects commits that don't follow this pattern with a helpful error message

This ensures all commits are machine-readable for semantic-release to properly determine version numbers.

## Viewing and Accessing Releases

You can access the released artifacts in several ways:

1. **Local Release Directory**:
   - After running `npm run release:local`, check the local `release` folder

2. **GitHub Releases**:
   - Visit the GitHub repository's Releases page to download JARs for specific versions
   - Each release includes automatically generated release notes based on commit messages

3. **GitHub Packages**:
   - Add the repository to your Maven `settings.xml` to use this package as a dependency:
   ```xml
   <repositories>
       <repository>
           <id>github</id>
           <url>https://maven.pkg.github.com/emboss/service-b</url>
       </repository>
   </repositories>
   ```

## Development

### Prerequisites
- JDK 21
- Node.js and npm (for semantic-release)
- Git

### Local Build
```bash
./mvnw clean package
```

### Creating a Release

To manually trigger a release locally:
```bash
npm run release:local
```

In CI environments, releases are typically triggered automatically after pushing or merging to the release branches.
See the `.github/workflows/release.yml` for details on the CI/CD pipeline.

## Intended Release Workflow & Best Practices

The intended workflow for this project is to adhere to the following Git branching model. We have three long-lived branches
that are used to manage the release process and ensure a smooth development cycle:

- **main**: Stable releases, always deployable
- **develop**: Ongoing development, features in progress. This is where developers merge their feature branches when deemed ready.
- **beta**: Prepare for production release, merged into `main` when ready. After calling "feature freeze",
  the current `develop` branch is merged into `beta` for final testing. When ready, `beta` is merged into `main` for release.
  Finally, `beta` is merged back into `develop` to keep it up to date, i.e. to not lose any changes/fixes made during the beta phase.

On top of these long-lived branches, we also use short-lived branches for specific purposes:

- **feature branches**: New features or fixes, merged into `develop` when complete
- **hotfix branches**: Critical fixes directly applied to `main` and merged back into `develop`

To avoid accidentally deleting the `develop` and `beta` branches, protect them in the GitHub repository settings.
Since developers will mostly interact with the `develop` branch, it is recommended to set it as the default branch in the repository settings.
Feature and hotfix branches should be created from `develop` or `main` as appropriate, and merged back into `develop` or `main` when complete.
They can be safely deleted after merging, as they are short-lived and do not affect the long-lived branches.

## GitHub Actions Workflow

The Github Actions workflow is configured to automatically run unit tests in the `Test` job any time a branch is pushed to Github.
If testing was successful, the `Release` job will run semantic-release on the `main`, `beta`, and `develop` branches. This ensures that
no releases are made without passing tests, and that the versioning and artifact publishing is handled automatically. At the same time,
developers can continue to work on new features in feature branches, which are merged into `develop` when ready. Feature branches will not trigger
a release, as semantic-release only runs on the `main`, `beta`, and `develop` branches.

## Example Release Scenario: Versioning Across Branches

### Scenario: Feature Development and Promotion

Suppose the current version on the `main` branch is **1.0.0**.

#### 1. Feature Branch → Develop

- A developer creates a feature branch and makes a single commit with the message:  
  `feat(api): add new endpoint`
- They open a pull request and merge the feature branch into `develop`.

**Effect:**  
- On `develop`, semantic-release is configured for pre-releases (e.g., `1.1.0-SNAPSHOT.1`).
- When the commit is merged, semantic-release analyzes the `feat` label and determines a **minor version bump**.
- The next pre-release version on `develop` becomes **1.1.0-SNAPSHOT.1** (or increments if previous pre-releases exist).
- Artifacts are published as pre-releases, not as stable releases.
- The snapshot version will be deployed to GitHub Packages, allowing developers to test the new feature immediately.

#### 2. Develop → Beta

- When development is ready for testing and/or to prepare a release using a release candidate, `develop` is merged into `beta`.

**Effect:**  
- On `beta`, semantic-release is configured for pre-releases (e.g., `1.1.0-beta.1`).
- semantic-release analyzes all new commits since the last `beta` release.
- The version is bumped to **1.1.0-beta.1** (or increments if previous beta pre-releases exist).
- Artifacts are published as beta pre-releases, suitable for final testing before production.
- The beta release will be deployed to GitHub Packages, and can be deployed on staging/testing servers as needed.

#### 3. Beta → Main

- After successful testing, `beta` is merged into `main` for production release.
  Note that bugs found during testing may still be fixed on `beta`. This should only happen after a "feature freeze" where
  no new features are added, and only critical fixes are allowed. In order to ensure that the `develop` branch is not
  left behind, the `beta` branch is merged back into `develop` after the release, i.e the merge into `main`.

**Effect:**  
- On `main`, semantic-release creates a stable release.
- All new commits since the last `main` release are analyzed.
- The version is bumped to **1.1.0** (from 1.0.0), reflecting the new feature.
- Artifacts are published as stable releases, and the JAR is attached to the GitHub Release and deployed to GitHub Packages.

---

### Branch Roles and Semantic-Release Reasoning

- **develop**:  
  Used for ongoing development. semantic-release publishes pre-release versions with the `SNAPSHOT` tag (e.g., `1.1.0-SNAPSHOT.1`).
  This allows developers to test integration without affecting production or beta users.

- **beta**:  
  Used for release candidates and final testing. semantic-release publishes pre-releases with the `beta` tag (e.g., `1.1.0-beta.1`).
  This is the staging area before production, allowing QA and stakeholders to validate the release.

- **main**:  
  Used for stable, production-ready releases. semantic-release publishes stable versions (e.g., `1.1.0`).
  Only thoroughly tested and approved changes reach this branch.

**Summary Table:**

| Branch   | Example Version         | Release Type      | Audience         |
|----------|------------------------|-------------------|------------------|
| develop  | 1.1.0-SNAPSHOT.1       | Pre-release       | Developers       |
| beta     | 1.1.0-beta.1           | Beta pre-release  | Testers/QA       |
| main     | 1.1.0                  | Stable release    | Production users |

**Why this matters:**  
This branching and release strategy ensures that:
- New features and fixes are tested in isolation (`develop`).
- Release candidates are validated before production (`beta`).
- Developers can safely work on new features without affecting production stability since they may continue to merge new features
  into `develop` but at the same time, the `beta` branch is frozen for new features and only critical fixes are allowed.
- Only stable, verified code is released to users (`main`).
- semantic-release automates versioning and artifact publishing at each stage, reducing manual errors and ensuring consistency.
  Ideally, developers should not have to worry about version numbers, as semantic-release handles it based on commit messages.

### Examples of Version Bumps

| Scenario                | Branch Action                        | Commit Message Example                  | Resulting Version (per branch)      |
|-------------------------|--------------------------------------|-----------------------------------------|-------------------------------------|
| **Minor bump**          | `feature/add-search` → `develop`     | `feat(search): add search endpoint`     | `develop`: `1.1.0-SNAPSHOT.1`      |
|                         | `develop` → `beta`                   | (merge PR, no new commit)               | `beta`: `1.1.0-beta.1`              |
|                         | `beta` → `main`                      | (merge PR, no new commit)               | `main`: `1.1.0`                     |
| **Bugfix bump**         | `feature/fix-login` → `develop`      | `fix(auth): correct login bug`          | `develop`: `1.0.1-SNAPSHOT.1`      |
|                         | `develop` → `beta`                   | (merge PR, no new commit)               | `beta`: `1.0.1-beta.1`              |
|                         | `beta` → `main`                      | (merge PR, no new commit)               | `main`: `1.0.1`                     |
| **Major bump**          | `feature/remove-legacy-api` → `develop` | `feat!: remove legacy API endpoints` | `develop`: `2.0.0-SNAPSHOT.1`      |
|                         | `develop` → `beta`                   | (merge PR, no new commit)               | `beta`: `2.0.0-beta.1`              |
|                         | `beta` → `main`                      | (merge PR, no new commit)               | `main`: `2.0.0`                     |

**Legend:**  
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/).
- `feat:` triggers a minor bump, `fix:` triggers a patch, `feat!:` (or `BREAKING CHANGE`) triggers a major bump.
- Version numbers increment as changes are promoted through `develop` → `beta` → `main`.

## When Things Go Wrong: Yanking Versions or Tags and Resetting semantic-release

If you need to **yank specific versions or tags** and/or **reset the versioning state** for semantic-release, here are your main options:

### Deleting Git Tags and GitHub Releases

- **Delete the Git tag locally and remotely:**
  ```bash
  git tag -d v1.2.3
  git push origin :refs/tags/v1.2.3
  ```
- **Delete the GitHub Release** (if created) via the GitHub web UI or using the [GitHub CLI](https://cli.github.com/):
  ```bash
  gh release delete v1.2.3
  ```

### 2. Yanking Maven Packages from GitHub Packages

- **GitHub Packages does not support deleting individual versions** for Maven packages via the UI for public repos, but you can:
  - Delete the entire package (removes all versions).
  - For private repos, you can delete individual versions via the UI.

### 3. Resetting semantic-release Version State

semantic-release determines the next version based on:
- The latest Git tag on the release branch (e.g., `v1.2.3`)
- The commit history since that tag

**To "reset" the version:**
- **Delete or move the problematic tag(s)** as above.
- **Create a new tag** at the desired commit:
  ```bash
  git tag v1.2.2 <commit-sha>
  git push origin v1.2.2
  ```
- On the next run, semantic-release will use this tag as the base for version calculation.

### 4. Forcing the Next Version

semantic-release does **not** have a built-in "set next version" command, but you can:
- Use the [`semantic-release/git`](https://github.com/semantic-release/git) plugin to push a new tag.
- Or, **manually create a tag** as above.
- Or, use the [`--dry-run`](https://semantic-release.gitbook.io/semantic-release/usage/command-line-interface#dry-run) flag to preview what would happen.

If you want to **force a specific version** on the next release, you can:
- Use a commit message with a [release-as](https://github.com/semantic-release/commit-analyzer#release-rules) footer, e.g.:
  ```
  chore(release): prepare for 2.0.0

  [release-as: 2.0.0]
  ```
  This tells semantic-release to release the specified version.

#### 5. Hard Reset (Not Recommended for Public History)

- You can force-push to rewrite history, but this is disruptive and should be avoided unless absolutely necessary.


#### Summary Table

| Action                | How-To                                                                                  |
|-----------------------|----------------------------------------------------------------------------------------|
| Yank Git tag          | `git tag -d vX.Y.Z && git push origin :refs/tags/vX.Y.Z`                               |
| Delete GitHub Release | GitHub UI or `gh release delete vX.Y.Z`                                                |
| Yank Maven package    | Delete package/version in GitHub Packages UI (if possible)                             |
| Set next version      | Use `[release-as: X.Y.Z]` in commit, or manually tag desired version                   |
| Hard reset            | Rewrite history and force-push (use with caution)                                      |

---

**References:**
- [semantic-release FAQ: How to skip or redo a release?](https://semantic-release.gitbook.io/semantic-release/support/faq#how-to-skip-or-redo-a-release)
- [semantic-release: Release Rules](https://github.com/semantic-release/commit-analyzer#release-rules)

