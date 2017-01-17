build:
	docker-compose build

deploy: build test
	docker tag `docker images -q krihelinator_web` nagasaki45/krihelinator_web
	docker push nagasaki45/krihelinator_web
	ssh krihelinator.xyz " \
		docker-compose pull && \
		docker-compose run --rm web mix ecto.migrate && \
		docker-compose up -d \
	"

logs:
	docker logs -f krihelinator_web_1 | less +F

test:
	docker-compose run --rm web mix test

.PHONY: test
