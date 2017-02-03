build:
	docker-compose build

deploy: build
	docker tag `docker images -q krihelinator_web` nagasaki45/krihelinator_web
	docker push nagasaki45/krihelinator_web
	ssh krihelinator.xyz " \
		docker-compose pull && \
		docker-compose run --rm web mix ecto.migrate && \
		docker-compose up -d \
	"

logs:
	docker logs -f krihelinator_web_1 | less +F

functional_tests:
	cd functional_tests && source env/bin/activate && pytest

.PHONY: functional_tests
