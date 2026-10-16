# docker-rock
Rock R server in a Docker container

The image is based on [rocker/r-ver](https://rocker-project.org/images/versioned/r-ver.html) and runs Rock on an Eclipse Temurin 25 JRE. The `-native` tagged variant (`Dockerfile.native`) runs Rock as a native executable instead (no Java runtime, faster startup and lower memory footprint, but Serial GC only). R packages are installed as prebuilt binaries from [Posit Package Manager](https://p3m.dev); set `ROCK_REPOS` (comma-separated) to use other repositories.

## Build and test locally

```
make build no_cache=false   # build obiba/rock:snapshot (options: rock_version, r_version, tag)
make build-native no_cache=false  # build obiba/rock:snapshot-native
make run                    # start it on port 8085 with an administrator/password user (tag=snapshot-native for the native variant)
make test                   # smoke test of the REST API
make stop
```

## Logging configuration (native variant)

A custom `conf/logback.xml` can only use the appenders, filters and policies registered in Rock's native image hints (console, rolling file with fixed window and size-based policies, threshold filter). Any other logback class makes Rock fail at startup.
