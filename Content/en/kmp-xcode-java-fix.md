---
author: Igor Ferreira
title: Kotlin Multiplatform: Fixing Java Version Conflicts in the Xcode Build Phase
description: A small fix to Java version when running iOS' build of KMP
date: 2026-02-23 12:00
tags: iOS, SwiftUI, KMP, Kotlin
published: true
language: en
---

# Kotlin Multiplatform: Fixing Java Version Conflicts in the Xcode Build Phase

If you've been working with Kotlin Multiplatform for a while, chances are you have more than one Java SDK installed on your machine. Android development, Spring Framework, CLI tooling -- they don't all agree on which Java version they want, and managing that is just part of the job.

Most of the time, your shell profile handles it gracefully. But there's one place where that setup quietly breaks down: the Xcode Build Phase.

## Why Xcode doesn't see your Java config

When the KMP project template sets up the iOS target, it adds a Build Phase script that calls `embedAndSignAppleFrameworkForXcode` on your shared Gradle project. The catch is that Xcode runs this script in its own isolated bash environment, one that doesn't source your `.zshrc`, `.bash_profile`, or wherever you've configured your Java toolchain. So instead of picking up the version you intended, Gradle grabs whatever Java sits at the top of the system path. If that happens to be Java 25 and your project targets Java 21, the build fails.

## The fix

Before the fix, the default Build Phase script looks like this:

```shell
if [ "YES" = "$OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED" ]; then
  echo "Skipping Gradle build task invocation due to OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED environment variable set to \"YES\""
  exit 0
fi
cd "$SRCROOT/.."
./gradlew :shared:embedAndSignAppleFrameworkForXcode
```

The solution is to set `JAVA_HOME` inline, scoped to just that Gradle invocation, using macOS's built-in `java_home` utility:

```shell
if [ "YES" = "$OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED" ]; then
  echo "Skipping Gradle build task invocation due to OVERRIDE_KOTLIN_BUILD_IDE_SUPPORTED environment variable set to \"YES\""
  exit 0
fi
cd "$SRCROOT/.."
JAVA_HOME="$(/usr/libexec/java_home -v21)" ./gradlew :shared:embedAndSignAppleFrameworkForXcode
```

The `/usr/libexec/java_home -v21` command resolves the full path to your Java 21 installation. Setting it inline means it only affects that single command, so nothing bleeds into the rest of the build environment.

Adjust the version flag to match whatever your project requires. If you're unsure which versions you have available, running `/usr/libexec/java_home -V` (capital V) will list them all.

## Worth keeping in mind

This is a template file, which means it gets regenerated if you ever re-run the KMP project setup. It's worth keeping a note of this change somewhere in your project -- a comment in the script itself works fine -- so it doesn't catch you off guard after an update.

---

Short, boring, and hopefully useful to someone hitting the same wall.
