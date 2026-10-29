# Verificações dos scripts de shell. `make` roda tudo.
SCRIPTS := bin/.local/bin/skills-sync scripts/testes-da-revisao \
           .githooks/pre-commit .githooks/post-merge

.PHONY: check lint fmt test

check: lint test

lint:
	shellcheck $(SCRIPTS)
	shfmt -i 4 -d $(SCRIPTS)

fmt:
	shfmt -i 4 -w $(SCRIPTS)

test:
	bats tests/ bin/.local/bin/
