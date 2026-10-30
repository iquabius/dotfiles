#!/usr/bin/env bats
# Testes do scripts/testes-da-revisao.
#
# Cada teste monta um repo de brinquedo com a forma dos dotfiles e põe à
# frente do PATH um make, um bats, um python3 e um distrobox-host-exec
# falsos, que só anotam a chamada em $LOG. REVISAO_CONTAINERENV aponta para
# um arquivo que não existe, salvo no teste do distrobox.

bats_require_minimum_version 1.5.0

SCRIPT="${TESTES_DA_REVISAO_SCRIPT:-$BATS_TEST_DIRNAME/../scripts/testes-da-revisao}"

setup() {
	export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
	export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
	# O git revisao pronto roda esta suíte com a base e a ponta do ramo dele
	# no ambiente, que não existem no repositório de brinquedo.
	unset GIT_REVISAO_BASE GIT_REVISAO_PONTA
	BIN=$BATS_TEST_TMPDIR/bin
	LOG=$BATS_TEST_TMPDIR/log
	mkdir -p "$BIN"
	for c in make bats python3 distrobox-host-exec; do
		printf '#!/bin/sh\necho "%s $*" >>"%s"\n' "$c" "$LOG" >"$BIN/$c"
		chmod +x "$BIN/$c"
	done
	export PATH=$BIN:$PATH REVISAO_CONTAINERENV=$BATS_TEST_TMPDIR/nenhum
	git init -q "$BATS_TEST_TMPDIR/repo"
	cd "$BATS_TEST_TMPDIR/repo"
	mkdir -p .config bin/.local/bin tests scripts outro pacote/.config \
		skills/s/.agents/skills/s/scripts skills/s/.agents/skills/s/tests \
		skills/t/.agents/skills/t/scripts
	for f in Makefile bin/.local/bin/a bin/.local/bin/a.test.bats \
		bin/.local/bin/b scripts/c tests/c.bats tests/ajuda.bash \
		bin/.local/bin/sobe bin/.local/bin/ação bin/.local/bin/ação.test.bats \
		bin/.local/bin/fala pacote/.config/liga.conf liga.conf \
		skills/s/.agents/skills/s/scripts/x.py skills/s/.agents/skills/s/tests/test_x.py \
		skills/t/.agents/skills/t/scripts/y outro/z leia.org; do
		echo 0 >"$f"
	done
	# Suítes que rodam outro script, pelo caminho, ou por um terceiro que o
	# acha no PATH e que a suíte cita; uma que cita um arquivo de
	# configuração de um pacote pelo caminho, cujo nome é também o de um
	# arquivo da raiz, outra que cita só esse nome, e outra que cita o
	# auxiliar de tests/; e outro/, um caminho de código que nenhuma suíte
	# cita.
	echo 'ln -s "$BATS_TEST_DIRNAME/../bin/.local/bin/sobe" x' >tests/usa.bats
	echo 'ln -s "$BATS_TEST_DIRNAME/sobe" x' >bin/.local/bin/vizinha.test.bats
	printf '%s\n' 'export PATH="$BATS_TEST_DIRNAME:$PATH"' \
		'run liga  # o liga chama o fala, que acha no PATH' \
		>bin/.local/bin/pelo-path.test.bats
	echo 'grep -q x "$BATS_TEST_DIRNAME/../pacote/.config/liga.conf"' >tests/liga.bats
	echo 'echo liga.conf >x' >tests/so-o-nome.bats
	echo '. "$BATS_TEST_DIRNAME/../../../tests/ajuda.bash"' >bin/.local/bin/a.test.bats
	printf '# código\nteste: x\n%s\n' .config/revisao Makefile .githooks/ \
		bin/.local/bin/ scripts/ tests/ outro/ pacote/.config/liga.conf liga.conf \
		'skills/*/.agents/skills/*/scripts/*' 'skills/*/.agents/skills/*/tests/*' \
		>.config/revisao
	git add . && git commit -qm raiz
	export GIT_REVISAO_BASE
	GIT_REVISAO_BASE=$(git rev-parse HEAD)
}

# muda <arquivo>... — acrescenta uma linha a cada um e commita.
muda() {
	for f in "$@"; do echo 1 >>"$f"; done
	git add "$@" && git commit -qm muda
}

@test "script com suíte ao lado roda o lint e a suíte" {
	muda bin/.local/bin/a
	run "$SCRIPT"
	[ "$status" -eq 0 ]
	[ "$(cat "$LOG")" = "make lint
bats bin/.local/bin/a.test.bats" ]
}

@test "suíte que mudou roda, uma vez só" {
	muda bin/.local/bin/a bin/.local/bin/a.test.bats
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make lint
bats bin/.local/bin/a.test.bats" ]
}

@test "script de scripts/ e a suíte dele rodam a suíte de tests/" {
	muda scripts/c tests/c.bats
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make lint
bats tests/c.bats" ]
}

@test "script sem suíte roda o make check" {
	muda bin/.local/bin/b
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make check" ]
}

@test "o que todas as suítes usam roda o make check" {
	for f in Makefile .config/revisao tests/ajuda.bash; do
		: >"$LOG"
		muda "$f"
		"$SCRIPT"
		[ "$(cat "$LOG")" = "make check" ]
		GIT_REVISAO_BASE=$(git rev-parse HEAD)
	done
}

@test "sem base, roda o make check" {
	muda leia.org
	GIT_REVISAO_BASE='' "$SCRIPT"
	[ "$(cat "$LOG")" = "make check" ]
}

@test "skill com testes roda a unittest dela; sem testes, só o lint" {
	muda skills/s/.agents/skills/s/scripts/x.py skills/t/.agents/skills/t/scripts/y
	run "$SCRIPT"
	[ "$status" -eq 0 ]
	[[ $output == *"unittest skills/s/.agents/skills/s/tests"* ]]
	[ "$(cat "$LOG")" = "make lint
python3 -B -m unittest discover -s tests -q" ]
}

@test "a suíte que roda o script pelo caminho roda também" {
	muda bin/.local/bin/sobe
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make lint
bats bin/.local/bin/vizinha.test.bats tests/usa.bats" ]
}

@test "a suíte que roda outro script, que chama este pelo PATH, roda também" {
	muda bin/.local/bin/fala
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make lint
bats bin/.local/bin/pelo-path.test.bats" ]
}

@test "ramo que tira o .config/revisao da lista ainda roda o make check" {
	sed -i -e '/^\.config\/revisao$/d' -e '/^scripts\/$/d' .config/revisao
	git commit -qam "estreita a lista"
	muda scripts/c
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make check" ]
}

@test "nome com acento escolhe a suíte dele" {
	muda bin/.local/bin/ação
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make lint
bats bin/.local/bin/ação.test.bats" ]
}

@test "arquivo de configuração roda o lint e as suítes que citam o caminho dele" {
	muda pacote/.config/liga.conf
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make lint
bats tests/liga.bats" ]
}

@test "arquivo de código da raiz roda o make check, mesmo com uma suíte que cita o nome dele" {
	muda liga.conf
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make check" ]
}

@test "caminho de código que nenhuma suíte cita roda o make check" {
	muda outro/z
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make check" ]
}

@test "texto não roda nada" {
	muda leia.org
	run "$SCRIPT"
	[ "$status" -eq 0 ]
	[ ! -e "$LOG" ]
}

@test "script de skill apagado roda a unittest da skill" {
	git rm -q skills/s/.agents/skills/s/scripts/x.py
	git commit -qm apaga
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make lint
python3 -B -m unittest discover -s tests -q" ]
}

@test "suíte apagada não trava o script" {
	git rm -q bin/.local/bin/a.test.bats
	git commit -qm apaga
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make lint" ]
}

@test "comentário com espaço antes não vira caminho" {
	printf '  # leia.org\n' >>.config/revisao
	git commit -qam comentario
	GIT_REVISAO_BASE=$(git rev-parse HEAD)
	muda leia.org
	run "$SCRIPT"
	[ "$status" -eq 0 ]
	[ ! -e "$LOG" ]
}

@test "olha só o intervalo, e não a árvore de trabalho" {
	muda bin/.local/bin/a
	echo solto >>bin/.local/bin/b
	"$SCRIPT"
	[ "$(cat "$LOG")" = "make lint
bats bin/.local/bin/a.test.bats" ]
}

@test "falha da suíte é a falha do script" {
	printf '#!/bin/sh\nexit 3\n' >"$BIN/bats"
	muda bin/.local/bin/a
	run "$SCRIPT"
	[ "$status" -eq 3 ]
}

@test "dentro do distrobox, sobe ao host e roda lá, com a base, a ponta e o diretório" {
	# O host falso roda o comando, como o de verdade: de outro diretório e
	# sem o ambiente de quem chama.
	printf '#!/bin/sh\necho distrobox-host-exec >>"%s"\ncd /\nexec env -u GIT_REVISAO_BASE -u GIT_REVISAO_PONTA "$@"\n' \
		"$LOG" >"$BIN/distrobox-host-exec"
	touch "$REVISAO_CONTAINERENV"
	muda bin/.local/bin/a
	# Depois da ponta, o script sem suíte pediria o make check.
	muda bin/.local/bin/b
	GIT_REVISAO_PONTA=HEAD~1 "$SCRIPT"
	[ "$(cat "$LOG")" = "distrobox-host-exec
make lint
bats bin/.local/bin/a.test.bats" ]
}
