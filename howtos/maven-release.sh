#!/usr/bin/env bash

set -e

BRANCH=$1
VERSION=$2
NEXT_SNAPSHOT=$3

if [ -z "$BRANCH" ] || [ -z "$VERSION" ] || [ -z "$NEXT_SNAPSHOT" ]; then
  echo "Usage: ./release.sh <branch> <version> <next-snapshot>"
  exit 1
fi

echo "Using branch: $BRANCH"
echo "Releasing version: $VERSION"
echo "Next snapshot: $NEXT_SNAPSHOT"

# Extract artifactId from pom.xml
ARTIFACT_ID=$(mvn help:evaluate -Dexpression=project.artifactId -q -DforceStdout)

if [ -z "$ARTIFACT_ID" ]; then
  echo "❌ Could not read artifactId from pom.xml"
  exit 1
fi

echo "ArtifactId: $ARTIFACT_ID"

echo "Starting dry run (build + tests)..."

# 1. Dry run
mvn clean verify

echo "✅ Dry run successful."

echo "Switching to release version..."

# 2. Set release version
mvn versions:set -DnewVersion=$VERSION -DgenerateBackupPoms=false

git add pom.xml
git commit -m "Release $VERSION"

TAG="${ARTIFACT_ID}-${VERSION}"
git tag -a "$TAG" -m "Release $VERSION"

echo "Deploying to Central Portal..."

mvn clean deploy -P release -DskipTests

echo "Pushing release..."

git push origin "$BRANCH"
git push origin "$TAG"

echo "Switching to next SNAPSHOT version..."

# 3. Set next snapshot version
mvn versions:set -DnewVersion=$NEXT_SNAPSHOT -DgenerateBackupPoms=false

git add pom.xml
git commit -m "Bump version to $NEXT_SNAPSHOT"

echo "Pushing snapshot version..."

git push origin "$BRANCH"

echo "🎉 Release complete: $VERSION → next: $NEXT_SNAPSHOT"