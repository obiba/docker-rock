#
# Docker helper
#

no_cache=false

all:
	sudo docker build --no-cache=true -t="obiba/rock:$(tag)" . && \
		sudo docker build -t="obiba/rock:latest" . && \
		sudo docker image push obiba/rock:$(tag) && \
		sudo docker image push obiba/rock:latest

# Build Docker image
build:
	sudo docker build --no-cache=$(no_cache) -t="obiba/rock:$(tag)" .

push:
	sudo docker image push obiba/rock:$(tag)
