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

## Running as a non-root user

The image starts as root by default: the entrypoint takes ownership of `ROCK_HOME` for the `rock` user (uid and gid 10041) and drops to it before starting Rock. Started as that user instead, with `--user 10041:10041` or `runAsUser: 10041` on Kubernetes, the entrypoint skips both steps and starts Rock directly, which is what a Pod Security `restricted` namespace (`runAsNonRoot`) needs. The volume's ownership is then yours to arrange: give it to uid 10041, or set `fsGroup: 10041` on the pod, or Rock will not be able to write its home.

## Logging configuration (native variant)

A custom `conf/logback.xml` can only use the appenders, filters and policies registered in Rock's native image hints (console, rolling file with fixed window and size-based policies, threshold filter). Any other logback class makes Rock fail at startup.
