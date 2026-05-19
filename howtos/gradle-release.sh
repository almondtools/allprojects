#!/usr/bin/env bash

set -euo pipefail

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

# Extract artifactId from gradle properties
ARTIFACT_ID=$(./gradlew properties -q | grep "^name:" | awk '{print $2}')

if [ -z "$ARTIFACT_ID" ]; then
  echo "❌ Could not determine artifact id"
  exit 1
fi

echo "ArtifactId: $ARTIFACT_ID"

# Ensure clean git state
if [[ -n $(git status --porcelain) ]]; then
  echo "❌ Git working tree is not clean"
  exit 1
fi

echo "Running verification build..."

./gradlew clean build

echo "Build successful"

echo "Switching to release version..."

sed -i.bak "s/^version=.*/version=$VERSION/" gradle.properties
rm gradle.properties.bak

echo "Verifying release build..."

./gradlew clean build

git add gradle.properties
git commit -m "Release $VERSION"

TAG="${ARTIFACT_ID}-${VERSION}"
git tag -a "$TAG" -m "Release $VERSION"

echo "Publishing to Maven Central..."

./gradlew clean publishAggregationToCentralPortal

echo "Published successfully"

echo "Pushing release..."

git push origin "$BRANCH"
git push origin "$TAG"

echo "Switching to next SNAPSHOT version..."

sed -i.bak "s/^version=.*/version=$NEXT_SNAPSHOT/" gradle.properties
rm gradle.properties.bak

git add gradle.properties
git commit -m "Bump version to $NEXT_SNAPSHOT"

echo "Pushing snapshot version..."

git push origin "$BRANCH"

echo "🎉 Release complete: $VERSION → next: $NEXT_SNAPSHOT"