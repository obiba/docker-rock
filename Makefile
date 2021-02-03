#
# Docker helper
#

no_cache=false

# Build Docker image
build:
	sudo docker build --no-cache=$(no_cache) -t="obiba/rock:snapshot" .

build-version:
	sudo docker build --no-cache=$(no_cache) -t="obiba/rock:$(version)" $(version)

run:
	sudo docker run -d -p 6312:6312 --name rock obiba/rock:snapshot

pull:
	sudo docker pull obiba/rock:snapshot

stop:
	sudo docker stop rock

start:
	sudo docker start rock

rm:
	sudo docker rm rock
