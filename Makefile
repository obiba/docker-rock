#
# Docker helper
#

tag=snapshot
no_cache=true
r_version=4.6.1
rock_version=2.3.0
port=8085
user=administrator
password=password

# Build Docker image
build:
	docker build --pull --no-cache=$(no_cache) --build-arg R_VERSION=$(r_version) --build-arg ROCK_VERSION=$(rock_version) -t="obiba/rock:$(tag)" . --progress=plain

push:
	docker image push obiba/rock:$(tag)

# Run the built image locally, test it, then stop it
run:
	docker run -d --rm --name rock-$(tag) -p $(port):8085 -e ROCK_ADMINISTRATOR_NAME=$(user) -e ROCK_ADMINISTRATOR_PASSWORD=$(password) obiba/rock:$(tag)

test:
	ROCK_URL=http://localhost:$(port) ROCK_USER=$(user) ROCK_PASSWORD=$(password) ./scripts/smoke-test.sh

logs:
	docker logs -f rock-$(tag)

stop:
	docker stop rock-$(tag)
