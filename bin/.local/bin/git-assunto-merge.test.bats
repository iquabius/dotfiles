#!/usr/bin/env bats
# Testes do git-assunto-merge, que mora ao lado deste arquivo. Cada teste cria
# um repositório descartável com um ramo; o hook entra pelo .git/hooks do
# repositório, e não pela configuração global, para a suíte rodar também em
# git anterior ao 2.54.

bats_require_minimum_version 1.5.0

SCRIPT="${GIT_ASSUNTO_MERGE_SCRIPT:-$BATS_TEST_DIRNAME/git-assunto-merge}"

setup() {
	export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
	export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
	cd "$BATS_TEST_TMPDIR"
	git init -q -b main repo
	cd repo
	printf '#!/bin/sh\nexec "%s" commit-msg "$@"\n' "$SCRIPT" >.git/hooks/commit-msg
	chmod +x .git/hooks/commit-msg
	git commit -q --allow-empty -m base
	git switch -q -c tarefa
	git commit -q --allow-empty -m 'Faz a tarefa'
	git switch -q main
	git commit -q --allow-empty -m 'Anda o main'
}

@test "merge sem -m: recusa o Merge branch e dá o comando que conclui" {
	run git merge -q --no-ff tarefa
	[ "$status" -ne 0 ]
	[[ $output == *"Merge branch 'tarefa'"* ]]
	[[ $output == *"git commit -m \"Junta o ramo tarefa: <o que o ramo traz>\""* ]]
	# O merge fica por concluir, e o comando da recusa o conclui.
	git rev-parse -q --verify MERGE_HEAD
	run git commit -q -m 'Junta o ramo tarefa: a tarefa feita'
	[ "$status" -eq 0 ]
	[ "$(git log -1 --format=%s)" = "Junta o ramo tarefa: a tarefa feita" ]
	[ "$(git rev-parse HEAD^2)" = "$(git rev-parse tarefa)" ]
}

@test "--amend de um merge já feito: recusa e dá o --amend que o conserta" {
	git merge -q --no-ff --no-verify tarefa
	merge=$(git rev-parse HEAD)
	run git commit -q --amend --no-edit
	[ "$status" -ne 0 ]
	# Não há merge por concluir: o git commit -m faria um commit novo.
	[[ $output != *"por concluir"* ]]
	[[ $output == *"git commit --amend -m \"Junta o ramo tarefa: <o que o ramo traz>\""* ]]
	[ "$(git rev-parse HEAD)" = "$merge" ]
	run git commit -q --amend -m 'Junta o ramo tarefa: a tarefa feita'
	[ "$status" -eq 0 ]
	[ "$(git rev-parse HEAD^2)" = "$(git rev-parse tarefa)" ]
}

@test "commit comum com o assunto do merge: nem conclui nem emenda" {
	run git commit -q --allow-empty -m "Merge branch 'tarefa'"
	[ "$status" -ne 0 ]
	# O HEAD não é merge: o --amend reescreveria o commit de antes.
	[[ $output != *"--amend"* ]]
	[[ $output != *"por concluir"* ]]
	[[ $output == *"git commit -m \"Junta o ramo tarefa: <o que o ramo traz>\""* ]]
}

@test "merge com HEAD solto: o ramo do comando não leva o into HEAD" {
	git switch -q --detach main
	run git merge -q --no-ff tarefa
	[ "$status" -ne 0 ]
	[[ $output == *"Merge branch 'tarefa' into HEAD"* ]]
	[[ $output == *"\"Junta o ramo tarefa: <o que o ramo traz>\""* ]]
}

@test "merge com o assunto Junta o ramo passa" {
	run git merge -q --no-ff -m 'Junta o ramo tarefa: a tarefa feita' tarefa
	[ "$status" -eq 0 ]
	[ "$(git log -1 --format=%s)" = "Junta o ramo tarefa: a tarefa feita" ]
}

@test "Junta o ramo sem dizer o que o ramo traz é recusado" {
	run git merge -q --no-ff -m 'Junta o ramo tarefa:' tarefa
	[ "$status" -ne 0 ]
	[[ $output == *"o que o ramo traz"* ]]
	run git commit -q -m 'Junta o ramo tarefa: <o que o ramo traz>'
	[ "$status" -ne 0 ]
	run git commit -q -m 'Junta o ramo tarefa:   '
	[ "$status" -ne 0 ]
	run git commit -q -m 'Junta o ramo tarefa: a tarefa feita'
	[ "$status" -eq 0 ]
}

@test "o merge de um pull e o commit comum passam" {
	run git commit -q --allow-empty -m "Merge branch 'main' of github.com:fulano/repo"
	[ "$status" -eq 0 ]
	run git commit -q --allow-empty -m 'Conserta o teste'
	[ "$status" -eq 0 ]
}

@test "conta o assunto depois das linhas de comentário" {
	printf "# comentário do editor\n\nMerge branch 'tarefa'\n" >"$BATS_TEST_TMPDIR/msg"
	run "$SCRIPT" commit-msg "$BATS_TEST_TMPDIR/msg"
	[ "$status" -ne 0 ]
	[[ $output == *"Junta o ramo tarefa"* ]]
	printf '# comentário do editor\nConserta o teste\n' >"$BATS_TEST_TMPDIR/msg"
	run "$SCRIPT" commit-msg "$BATS_TEST_TMPDIR/msg"
	[ "$status" -eq 0 ]
}
