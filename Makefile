
enable_melos:
	fvm dart pub global activate melos

enable_serverpod:
	fvm dart pub global activate serverpod_cli 4.0.0-beta.2
	fvm dart pub global activate serverpod_mcp

enable_jaspr:
	fvm dart pub global activate jaspr_cli

enable_tools:
	fvm dart pub global activate flutter_plugin_tools

ensure_flutter_version:
	fvm install 3.44.9
	fvm use 3.44.9
	fvm global 3.44.9

update_flutter_version:
	@if [ -z "$(NEW_VERSION)" ]; then \
        read -p "Enter new flutter version: " NEW_VERSION; \
    fi; \
    sh scripts/update_flutter_version.sh $$NEW_VERSION

update_serverpod_version:
	@if [ -z "$(NEW_VERSION)" ]; then \
        read -p "Enter new serverpod version: " NEW_VERSION; \
    fi; \
    sh scripts/update_serverpod_version.sh $$NEW_VERSION

init: enable_melos enable_serverpod enable_tools ensure_flutter_version enable_jaspr pub_get ## Initialize the project

flutter_clean:
	melos run clean

pub_get:
	fvm dart pub get

pub_clean:
	fvm dart pub cache clean --force

delete_generated_files:
	sh scripts/delete_generated_files.sh			

clean: flutter_clean delete_generated_files ## Clean the project

## Feature Creation
create_feature:
	@read -p "Choose app (admin/app/site): " app; \
	if [ "$$app" = "admin" ]; then \
		sh scripts/create_feature.sh --app baktaz_admin; \
	elif [ "$$app" = "app" ]; then \
		sh scripts/create_feature.sh --app baktaz_flutter; \
	elif [ "$$app" = "site" ]; then \
		sh scripts/create_feature.sh --app baktaz_site; \
	else \
		echo "Invalid app choice."; \
	fi

create_feature_tests:
	@read -p "Choose app (admin/app/site): " app; \
	if [ "$$app" = "admin" ]; then \
		sh scripts/create_feature_tests.sh --app baktaz_admin; \
	elif [ "$$app" = "app" ]; then \
		sh scripts/create_feature_tests.sh --app baktaz_flutter; \
	elif [ "$$app" = "site" ]; then \
		sh scripts/create_feature_tests.sh --app baktaz_site; \
	else \
		echo "Invalid app choice."; \
	fi

## Serverpod Commands
server_run: docker_run server_apply_migrations

server_start:
	cd baktaz_server && fvm dart run serverpod start --watch

server_apply_migrations:
	cd baktaz_server && fvm dart bin/main.dart --apply-migrations

server_seed:
	cd baktaz_server && fvm dart bin/seed.dart --role maintenance

server_gen:
	cd baktaz_server && fvm dart run build_runner build --delete-conflicting-outputs
	cd baktaz_server && serverpod generate

server_gen_watch:
	cd baktaz_server && serverpod generate watch		

server_migration: 
	cd baktaz_server && serverpod create-migration

server_migration_force: 
	cd baktaz_server && serverpod create-migration --force

docker_run:
	cd baktaz_server && docker compose up --build --detach

docker_open:
	cd /d C:\Program Files\Docker\Docker && "Docker Desktop.exe"

## Site Commands
site_serve:
	cd baktaz_site && PATH="$$HOME/bin:$$PATH" fvm dart pub global run jaspr_cli:jaspr serve

## Coverage Reports
lcov: 
	@read -p "Choose app (admin/server/app/site/shared): " app; \
	sh scripts/generate_lcov.sh $$app

## iOS & Android specific updates
clean_pods:
	sh scripts/clean_pods.sh

update_android_project:
	cd baktaz_flutter && sh ../scripts/update_android_project.sh

## Tests
test: ## Run tests interactively (select packages)
	@sh scripts/run_tests.sh

test_all: ## Run tests for all packages
	@sh scripts/run_tests.sh all

test_admin: ## Run tests for baktaz_admin
	@sh scripts/run_tests.sh baktaz_admin

test_app: ## Run tests for baktaz_flutter
	@sh scripts/run_tests.sh baktaz_flutter

test_shared: ## Run tests for baktaz_shared
	@sh scripts/run_tests.sh baktaz_shared

test_server: ## Run tests for baktaz_server
	@sh scripts/run_tests.sh baktaz_server

test_site: ## Run tests for baktaz_site
	@sh scripts/run_tests.sh baktaz_site

codebase_graph: ## Open codebase graph in browser http://localhost:9749
	(sleep 1.5 && open http://localhost:9749) & \
	codebase-memory-mcp --ui=true --port=9749
	
init_session: ## Launch dev session terminals (Ollama + Agentmemory)
	sh scripts/init_session.sh

ollama_serve: ## Start the Ollama server in the foreground
	ollama serve

agentmemory:
	npx @agentmemory/agentmemory

agentmemory_viewer:
	open http://localhost:3114

graphify-view:
	@if [ -f graphify-out/graph.html ]; then \
		if command -v open >/dev/null; then open graphify-out/graph.html; \
		elif command -v xdg-open >/dev/null; then xdg-open graphify-out/graph.html; \
		elif command -v start >/dev/null; then start graphify-out/graph.html; \
		else echo "Open graphify-out/graph.html manually in your browser"; fi \
	else \
		echo "graphify-out/graph.html not found. Run graphify build first."; \
	fi
