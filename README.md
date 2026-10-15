# docker-rock
Rock R server in a Docker container

The image is based on [rocker/r-ver](https://rocker-project.org/images/versioned/r-ver.html) and runs Rock as a native executable (no Java runtime). R packages are installed as prebuilt binaries from [Posit Package Manager](https://p3m.dev); set `ROCK_REPOS` (comma-separated) to use other repositories.

## Build and test locally

```
make build no_cache=false   # build obiba/rock:snapshot (options: rock_version, r_version, tag)
make run                    # start it on port 8085 with an administrator/password user
make test                   # smoke test of the REST API
make stop
```

## Logging configuration

A custom `conf/logback.xml` can only use the appenders, filters and policies registered in Rock's native image hints (console, rolling file with fixed window and size-based policies, threshold filter). Any other logback class makes Rock fail at startup.
