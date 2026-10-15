# ensure HOME system env variable
home <- Sys.getenv("HOME")
if (home == "") {
    Sys.setenv(HOME="/var/lib/rock")
    home <- Sys.getenv("HOME")
}
# install R libraries in a R version independent directory
libPath <- file.path(home, "R", "library")
if (!dir.exists(libPath)) {
  dir.create(libPath, recursive=TRUE)
}
.libPaths(libPath)
# cleanup
rm(home)
rm(libPath)
options(repos = strsplit(Sys.getenv("ROCK_REPOS", "https://cloud.r-project.org"), ",")[[1]])
# Posit Package Manager serves binaries only to this User-Agent (set by rocker in Rprofile.site, which Rserve skips)
options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))
# newline required
