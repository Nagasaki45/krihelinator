build:
	docker-compose build

deploy: build
	docker tag `docker images -q krihelinator_web` nagasaki45/krihelinator_web
	docker push nagasaki45/krihelinator_web
	# TODO continue with ssh.

logs:
	docker logs -f krihelinator_web_1 | less +F
