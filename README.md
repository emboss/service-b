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
- Branch configuration (releases from `main` branch)
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

### Running the Application
```bash
java -jar target/service-b-x.y.z.jar
```
The service will start on port 8081.

### Creating a Release
To manually trigger a release locally:
```bash
npm run release:local
```

In CI environments, releases are typically triggered automatically after merging to the main branch.

## Version Information

The application's version is available at runtime through:
- The `/api/version` endpoint
- Injected into `application.properties` as `api.version`