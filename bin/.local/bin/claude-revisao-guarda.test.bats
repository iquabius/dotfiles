#!/usr/bin/env bats
# Testes do claude-revisao-guarda, o hook PreToolUse do Claude Code que
# guarda o ciclo de ramo, revisão e merge. O hook só lê o comando: não roda
# git nem gh.

bats_require_minimum_version 1.5.0

SCRIPT="${CLAUDE_REVISAO_GUARDA_SCRIPT:-$BATS_TEST_DIRNAME/claude-revisao-guarda}"

# guarda <comando> — roda o hook com o JSON que o Claude Code manda.
guarda() {
	python3 -c 'import json,sys; print(json.dumps({"tool_name": "Bash", "tool_input": {"command": sys.argv[1]}}))' "$1" |
		"$SCRIPT"
}

recusa() { [[ $output == *'"permissionDecision": "deny"'* ]]; }
pergunta() { [[ $output == *'"permissionDecision": "ask"'* ]]; }

@test "commit comum e no ramo passam calados" {
	for c in 'git commit -m "x"' 'git commit -am "x"' 'git commit -qm "y" -- bin/x' \
		'git -C ~/x commit -F msg' 'git commit --amend --no-edit' 'git switch -c tarefa'; do
		run guarda "$c"
		[ "$status" -eq 0 ]
		[ -z "$output" ]
	done
}

@test "commit com --no-verify ou -n é recusado, também agrupado" {
	for c in 'git commit --no-verify -m x' 'git commit -n -m x' 'git commit -anm x' \
		'git commit -m x -n' 'cd ~/x && git commit -qn -m x'; do
		run guarda "$c"
		recusa
	done
}

@test "--no-verify abreviado, opção global do git e command git também são recusados" {
	for c in 'git commit --no-verif -m x' 'git -P commit -n -m x' \
		'git --git-dir .git commit -n -m x' 'command git commit -n -m x'; do
		run guarda "$c"
		recusa
	done
}

@test "-uno e -S não são lidos como -n" {
	for c in 'git commit -uno -m x' 'git commit -S -m x' 'git commit -Snome -m x'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "trocar a configuração global pelo ambiente num commit, merge ou push é recusado" {
	for c in 'GIT_CONFIG_GLOBAL=/dev/null git commit -m x' 'HOME=/tmp/x git push' \
		'export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath; git commit -m x' \
		'XDG_CONFIG_HOME=/tmp git merge --no-ff t'; do
		run guarda "$c"
		recusa
	done
	for c in 'GIT_CONFIG_GLOBAL=/dev/null git log' 'HOME=/tmp/x ls'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "configuração citada em mensagem, heredoc ou leitura não conta" {
	for c in 'git commit -m "Testa com GIT_CONFIG_GLOBAL=/dev/null"' \
		$'git commit -F - <<\'EOF\'\nTestado com HOME=/tmp/x e git push.\nEOF' \
		$'cat >x.sh <<\'EOF\'\nexport GIT_CONFIG_GLOBAL=/dev/null\ngit commit -n -m x\nEOF' \
		'git config --get core.hooksPath' 'CLAUDECODE=1 bats x.bats' \
		'git notes --ref=revisao show origin/merge-fix'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "heredoc sem aspas, here-string e delimitador falso não escondem comando" {
	for c in $'cat >/dev/null <<EOF\n$(git commit -n -m x)\nEOF' \
		$'cat <<<x\ngit commit -n -m y\nx' $'echo "<<EOF"\ngit commit -n -m x\nEOF' \
		$'cat <<\'END-OF\'\ntexto\nEND\ngit commit -n -m x\nEND-OF'; do
		run guarda "$c"
		recusa
	done
}

@test "configuração do git no ambiente antes de qualquer git que grava é recusada" {
	for c in 'HOME=/x && git commit -m x' 'HOME=/x;git commit -m x' \
		'HOME=/x; export HOME; git push' 'declare -x HOME=/x; git commit -m x' \
		'HOME=/x git --git-dir .git commit -m x' 'HOME=/x nohup git push' \
		'env HOME=/x git commit -m x'; do
		run guarda "$c"
		recusa
	done
}

@test "muitas linhas de atribuição não estouram o tempo do hook" {
	cmd=$(for i in $(seq 400); do printf 'HOME=/x%s A=1 B=2\n' "$i"; done)
	SECONDS=0
	run guarda "$cmd"
	[ "$SECONDS" -lt 3 ]
	run guarda "$cmd"$'\ngit push'
	recusa
}

@test "env na frente do git não esconde o --no-verify" {
	for c in 'env git commit -n -m x' 'env -S git commit --no-verify -m x' \
		'env FOO=1 git commit -n -m x'; do
		run guarda "$c"
		recusa
	done
}

@test "comando depois do heredoc continua contando" {
	run guarda $'cat >x <<\'EOF\'\ntexto\nEOF\ngit commit -n -m x'
	recusa
}

@test "escrever as notas da revisão à mão é recusado; lê-las passa" {
	for c in 'git notes --ref=revisao add -m "revisao: exceção" HEAD' \
		'git notes --ref revisao remove HEAD' 'git update-ref refs/notes/revisao HEAD'; do
		run guarda "$c"
		recusa
	done
	for c in 'git notes --ref=revisao show HEAD' 'git notes --ref=revisao list' 'git notes add -m x'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "-n dentro da mensagem ou como argumento de -m não conta" {
	for c in 'git commit -m "-n"' 'git commit -m "aceita -n no push"' \
		'git commit --message -n' 'git commit -mn'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "mexer em core.hooksPath é recusado, em qualquer grafia" {
	for c in 'git -c core.hooksPath=/dev/null commit -m x' \
		'git config core.hooksPath /dev/null' 'git config --unset core.hookspath'; do
		run guarda "$c"
		recusa
	done
}

@test "tirar CLAUDECODE do ambiente é recusado" {
	for c in 'CLAUDECODE= git commit -m x' 'unset CLAUDECODE; git commit -m x' \
		'env -u CLAUDECODE git commit -m x' 'env --unset=CLAUDECODE git commit' \
		'env -i PATH=/usr/bin git commit -m x' 'export CLAUDECODE=0'; do
		run guarda "$c"
		recusa
	done
}

@test "env CLAUDECODE= e comando dentro de sh -c também são recusados" {
	for c in 'env CLAUDECODE= git commit -am x' "sh -c 'unset CLAUDECODE; git commit -m x'" \
		'bash -lc "git commit --no-verify -m x"' "/bin/sh -c \"bash -c 'gh pr merge 3'\""; do
		run guarda "$c"
		recusa
	done
	run guarda "sh -c 'git commit -m x'"
	[ -z "$output" ]
}

@test "recusa num shell interno vence a pergunta de fora" {
	run guarda "git revisao excecao -m x; sh -c 'git commit -n -m y'"
	recusa
}

@test "merge pelo GitHub é recusado" {
	for c in 'gh pr merge 12 --squash' 'gh api -X PUT repos/o/r/pulls/3/merge' \
		'gh api repos/o/r/merges -f base=main -f head=x' \
		"gh api graphql -f query='mutation { mergePullRequest(input: {pullRequestId: \"x\"}) { clientMutationId } }'" \
		"gh api graphql -f query='mutation { enablePullRequestAutoMerge(input: {pullRequestId: \"x\"}) { clientMutationId } }'"; do
		run guarda "$c"
		recusa
	done
	run guarda 'gh pr view 12'
	[ -z "$output" ]
}

@test "git revisao excecao pergunta ao autor; pronto e pendente passam" {
	run guarda 'git revisao excecao -m "o autor aceitou"'
	pergunta
	run guarda '~/.local/bin/git-revisao excecao -m x'
	pergunta
	for c in 'git revisao pronto' 'git revisao pendente'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "comando citado num texto não conta" {
	texto=$'cat >>AGENTS.md <<EOF\nNunca rode =git commit --no-verify= nem =unset CLAUDECODE=; o =gh pr merge= fica de fora.\nEOF'
	run guarda "$texto"
	[ -z "$output" ]
}

@test "outra ferramenta que não o Bash passa" {
	run sh -c 'echo "{\"tool_name\":\"Edit\",\"tool_input\":{}}" | "$0"' "$SCRIPT"
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}
