# JDK 17 Compatibility with XGBoost

This document explains the compatibility issues between JDK 17 and XGBoost, and how they are addressed in our scripts.

## The Problem

When compiling XGBoost with JDK 17, you may encounter the following error:

```
scala.reflect.internal.MissingRequirementError: object java.lang.Object in compiler mirror not found.
```

This error occurs because the Scala compiler used in the XGBoost project is not fully compatible with JDK 17 by default. The issue is related to the Java Platform Module System (JPMS) introduced in Java 9, which restricts access to internal JDK APIs that Scala relies on.

## The Solution

To fix this issue, we need to add specific JVM arguments that open up the required modules to the Scala compiler. This is done by:

1. Adding `--add-opens` JVM arguments to the Maven configuration
2. Setting the `MAVEN_OPTS` environment variable with the same arguments

The specific modules that need to be opened include:

- `java.base/java.lang`
- `java.base/java.lang.invoke`
- `java.base/java.lang.reflect`
- `java.base/java.io`
- `java.base/java.net`
- `java.base/java.nio`
- `java.base/java.util`
- `java.base/java.util.concurrent`
- `java.base/java.util.concurrent.atomic`
- `java.base/sun.nio.ch`
- `java.base/sun.nio.cs`
- `java.base/sun.security.action`
- `java.base/sun.util.calendar`

## Implementation

Our scripts implement this solution by:

1. Modifying the `pom.xml` file to add the JVM arguments to the Scala Maven plugin configuration
2. Modifying the `pom.xml` file to add the JVM arguments to the exec-maven-plugin configuration
3. Setting the `MAVEN_OPTS` environment variable with the same JVM arguments

This ensures that both the compilation and execution phases have the necessary access to the JDK internal APIs.

## Additional Notes

- This solution is specific to JDK 17 and may need to be adjusted for future JDK versions
- The `-DskipTests` flag is used to avoid test failures that may occur due to other compatibility issues
- This approach is a workaround and not a permanent solution; future versions of Scala and XGBoost may address these compatibility issues natively
