#!/usr/bin/env bats
# Testes do .githooks/post-merge.
#
# Cada teste monta um remoto e um clone de brinquedo em $BATS_TEST_TMPDIR,
# que faz de $HOME: o clone fica em ~/.dotfiles-private, onde o hook roda o
# stow. O hook entra pelo .git/hooks do clone, e o skills-sync do clone é um
# falso que só anota em $SYNC_LOG que foi chamado. O stow é o de verdade, e o
# bin do clone ainda não foi ligado em ~/.local/bin.

# POST_MERGE_SCRIPT troca o hook testado (útil para conferir, com uma cópia
# sabotada, que o teste de fato pega a falha).
SCRIPT="${POST_MERGE_SCRIPT:-$BATS_TEST_DIRNAME/../.githooks/post-merge}"

setup() {
	export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
	export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
	export SYNC_LOG=$BATS_TEST_TMPDIR/sync.log
	unset SYNC_FALHA
	export HOME=$BATS_TEST_TMPDIR
	mkdir -p "$HOME/.local/bin"
	cd "$BATS_TEST_TMPDIR"
	git init -q -b main up
	mkdir -p up/bin/.local/bin up/skills/a up/profiles
	printf '#!/bin/sh\necho chamado >>"$SYNC_LOG"\n[ -z "$SYNC_FALHA" ]\n' \
		>up/bin/.local/bin/skills-sync
	chmod +x up/bin/.local/bin/skills-sync
	echo a >up/skills/a/SKILL.md
	echo a >up/profiles/base.pkgs
	echo texto >up/leia.org
	git -C up add .
	git -C up commit -qm raiz
	git clone -q up .dotfiles-private
	cd .dotfiles-private
	git config pull.rebase false
	printf '#!/bin/sh\nexec "%s" "$@"\n' "$SCRIPT" >.git/hooks/post-merge
	chmod +x .git/hooks/post-merge
	echo base >.profile.local
}

# muda <repo> <arquivo> — acrescenta uma linha e commita.
muda() {
	mkdir -p "$(dirname "$1/$2")"
	echo "$RANDOM" >>"$1/$2"
	git -C "$1" add "$2"
	git -C "$1" commit -qm "$2"
}

sincronizou() {
	[ -s "$SYNC_LOG" ]
}

# Não "! sincronizou": o bats só reprova com ! na última linha do teste.
nao_sincronizou() {
	[ ! -e "$SYNC_LOG" ]
}

@test "pull que só muda texto não roda o skills-sync" {
	muda ../up leia.org
	run git pull -q
	[ "$status" -eq 0 ]
	nao_sincronizou
	[ -z "$output" ]
}

@test "pull que traz skill nova roda o skills-sync" {
	muda ../up skills/b/SKILL.md
	git pull -q
	sincronizou
}

@test "pull que apaga uma skill roda o skills-sync" {
	git -C ../up rm -rq skills/a
	git -C ../up commit -qm "apaga a"
	git pull -q
	sincronizou
}

@test "pull que muda um perfil roda o skills-sync" {
	muda ../up profiles/base.pkgs
	git pull -q
	sincronizou
}

@test "pull que muda o próprio skills-sync roda o skills-sync" {
	echo "# conserto" >>../up/bin/.local/bin/skills-sync
	git -C ../up commit -qam "conserta o skills-sync"
	git pull -q
	sincronizou
}

@test "merge --no-ff de um ramo só de texto não roda o skills-sync" {
	git switch -qc tarefa
	muda . leia.org
	git switch -q main
	muda . outro.org
	git merge -q --no-ff -m junta tarefa
	nao_sincronizou
}

@test "pull com merge de verdade que traz skill roda o skills-sync" {
	muda ../up skills/b/SKILL.md
	muda . leia.org
	git pull -q --no-edit
	sincronizou
}

@test "merge --squash que traz skill roda o skills-sync, com o HEAD parado" {
	git switch -qc tarefa
	muda . skills/b/SKILL.md
	git switch -q main
	git merge -q --squash tarefa
	sincronizou
}

@test "sem ORIG_HEAD o hook roda o stow" {
	muda ../up bin/.local/bin/novo
	git pull -q
	rm "$HOME/.local/bin/novo"
	git update-ref -d ORIG_HEAD
	run .git/hooks/post-merge 0
	[ "$status" -eq 0 ]
	[ -L "$HOME/.local/bin/novo" ]
}

@test "sem ORIG_HEAD o hook roda o skills-sync" {
	# O pull só de texto deixa ORIG_HEAD e não sincroniza; sem ORIG_HEAD,
	# o mesmo merge tem de sincronizar.
	muda ../up leia.org
	git pull -q
	nao_sincronizou
	git update-ref -d ORIG_HEAD
	run git rev-parse -q --verify ORIG_HEAD
	[ "$status" -ne 0 ]
	run .git/hooks/post-merge 0
	[ "$status" -eq 0 ]
	sincronizou
}

@test "sem .profile.local: avisa e não roda o skills-sync" {
	rm .profile.local
	muda ../up skills/b/SKILL.md
	run git pull -q
	[ "$status" -eq 0 ]
	[[ $output == *"sem .profile.local"* ]]
	nao_sincronizou
}

@test "sem .profile.local, merge sem skills sai calado" {
	rm .profile.local
	muda ../up leia.org
	run git pull -q
	[ "$status" -eq 0 ]
	[ -z "$output" ]
	nao_sincronizou
}

@test "skills-sync que falha: avisa, e o merge não falha" {
	export SYNC_FALHA=1
	muda ../up skills/b/SKILL.md
	run git pull -q
	[ "$status" -eq 0 ]
	[[ $output == *"skills-sync falhou"* ]]
	[ -f skills/b/SKILL.md ]
}

@test "pull que traz script novo em bin o liga em ~/.local/bin" {
	muda ../up bin/.local/bin/novo
	git pull -q
	[ -L "$HOME/.local/bin/novo" ]
	[ "$(readlink -f "$HOME/.local/bin/novo")" = "$(readlink -f bin/.local/bin/novo)" ]
}

@test "pull que apaga um script de bin tira o link pendurado" {
	muda ../up bin/.local/bin/novo
	git pull -q
	[ -L "$HOME/.local/bin/novo" ]
	git -C ../up rm -q bin/.local/bin/novo
	git -C ../up commit -qm "apaga novo"
	git pull -q
	[ ! -L "$HOME/.local/bin/novo" ]
}

@test "pull que não muda bin não roda o stow" {
	muda ../up leia.org
	git pull -q
	[ -z "$(ls -A "$HOME/.local/bin")" ]
}

@test "sem ~/.local/bin: avisa, não roda o stow, e o merge não falha" {
	rmdir "$HOME/.local/bin"
	muda ../up bin/.local/bin/novo
	run git pull -q
	[ "$status" -eq 0 ]
	[[ $output == *"sem ~/.local/bin"* ]]
	[ ! -e "$HOME/.local/bin" ]
	[ -f bin/.local/bin/novo ]
}

@test "stow que falha: avisa, e o merge não falha" {
	echo meu >"$HOME/.local/bin/novo"
	muda ../up bin/.local/bin/novo
	run git pull -q
	[ "$status" -eq 0 ]
	[[ $output == *"stow -R bin falhou"* ]]
	[ "$(cat "$HOME/.local/bin/novo")" = meu ]
	[ -f bin/.local/bin/novo ]
}

@test "merge numa worktree que traz script novo não roda o stow" {
	git worktree add -q -b tarefa ../wt
	muda ../up bin/.local/bin/novo
	git fetch -q
	run git -C ../wt merge -q origin/main
	[ "$status" -eq 0 ]
	[ -z "$output" ]
	[ -f ../wt/bin/.local/bin/novo ]
	[ ! -e "$HOME/.local/bin/novo" ]
}
