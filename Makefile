VERSION = `cd krihelinator && mix project_info.version`
RELEASE_TAR = krihelinator/_build/prod/rel/krihelinator/releases/$(VERSION)/krihelinator.tar.gz

release:
	docker run --rm -v `pwd`/krihelinator:/opt/app/ -e MIX_ENV=prod bitwalker/alpine-elixir-phoenix mix local.hex --force
	docker run --rm -v `pwd`/krihelinator:/opt/app/ -e MIX_ENV=prod bitwalker/alpine-elixir-phoenix mix release

deploy: release
	scp $(RELEASE_TAR) krihelinator.xyz:
	scp -r production/* krihelinator.xyz:
	scp krihelinator/bigquery_private_key.json krihelinator.xyz:
	ssh krihelinator.xyz " \
		tar xf krihelinator.tar.gz && \
		docker-compose run --rm web /opt/app/bin/krihelinator migrate && \
		docker-compose up -d \
	"

functional_tests:
	cd functional_tests && source env/bin/activate && pytest

.PHONY: functional_tests
