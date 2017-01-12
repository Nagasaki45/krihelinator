build:
	docker build -t nagasaki45/krihelinator_web .

deploy: build
	docker push nagasaki45/krihelinator_web
	# TODO continue with ssh.

test:
	docker-compose run --rm web mix test
	docker-compose run --rm web mix credo

iex:
	docker-compose run --rm web iex -S mix

logs:
	docker logs -f krihelinator_web_1 | less +F

.PHONY: test
