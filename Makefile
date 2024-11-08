#
# Docker helper
#

no_cache=false

# Build Docker image
build:
	docker build --pull --no-cache=$(no_cache) -t="obiba/rock:$(tag)" . --progress=plain

push:
	docker image push obiba/rock:$(tag)
