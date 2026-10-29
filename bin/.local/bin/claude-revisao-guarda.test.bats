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
		$'bash <<\'EOF\'\ngit commit -n -m x\nEOF' $'git \\\ncommit -n -m x' \
		$'cat <<\'EOF\'; git commit -n -m x\ntexto\nEOF' \
		$'cat <<\'EOF\' && git commit -n -m x\ntexto\nEOF' \
		$'sudo bash <<EOF\ngit commit -n -m x\nEOF' $'env bash <<EOF\ngit commit -n -m x\nEOF' \
		$'bash 2>/dev/null <<\'EOF\'\ngit commit -n -m x\nEOF' \
		$'sudo bash <<\'END-OF\'\ngit commit -n -m x\nEND-OF' \
		"$(printf 'eval %.0s' 1 2 3 4 5 6 7 8 9 10 11 12)git commit -n -m x" \
		$'git commit \\\n-n' $'# comentário \\\ngit commit -n -m x'; do
		run guarda "$c"
		recusa
	done
}

@test "texto que não roda passa: heredoc, aspas simples, comentário, alias sem uso" {
	for c in $'cat <<\'END-OF\'\ntexto\nEND\ngit commit -n -m x\nEND-OF' \
		$'cat <<\'END-OF\'\n$(git commit -n -m x)\nEND-OF' \
		$'cat <<EOF\ngit commit -n -m x\nEOF' "echo '\$(git commit -n -m x)'" \
		"echo '\`git commit -n\`'" 'git commit -m text # --no-verify' \
		"git -c alias.x='commit -n -m x' status" 'env -u DEBUG git config --get core.hooksPath' \
		'git commit --mes "-n"' $'echo \'\nsh -c "git commit -n"\n\'' \
		'git config --get core.hooksPath # --unset' 'git config core.hooksPath # description' \
		'git config -f/tmp/settings --get core.hooksPath' 'command -v git commit -n' \
		"bash -c 'echo ok' <<< 'git commit -n'" "echo 'texto; unset CLAUDECODE'" \
		"git commit -m 'texto; git notes --ref=revisao add -m ok'" \
		"echo 'texto; gh pr merge 1'" "echo 'texto; git revisao excecao'" \
		"git commit -m 'texto; HOME=/tmp git push'" 'true # ; gh pr merge 1' \
		$'cat <<EOF > f\ngh pr merge 1\nEOF' $'cat <<EOF > f\nunset CLAUDECODE\nEOF' \
		$'bash -c \'cat\' <<EOF\ngit commit -n -m x\nEOF'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "configuração do git no ambiente antes de qualquer git que grava é recusada" {
	for c in 'HOME=/x && git commit -m x' 'HOME=/x;git commit -m x' \
		'HOME=/x; export HOME; git push' 'declare -x HOME=/x; git commit -m x' \
		'HOME=/x git --git-dir .git commit -m x' 'HOME=/x nohup git push' \
		'env HOME=/x git commit -m x' 'env -S "HOME=/tmp git commit -m x"' \
		'env -u HOME git commit -m x' 'env --unset=HOME git commit -m x' \
		"env GIT_CONFIG_GLOBAL=/dev/null bash -c 'git commit -m x'" \
		'HOME=/tmp git pull origin main' "eval 'HOME=/x git push'" \
		$'HOME=/x bash <<EOF\ngit push\nEOF' $'GIT_CONFIG_GLOBAL=/dev/null sh <<\'FIM\'\ngit commit -m x\nFIM'; do
		run guarda "$c"
		recusa
	done
	for c in 'HOME=/x git status' 'env -u DEBUG git commit -m x' 'export PATH=/x:$PATH; git push'; do
		run guarda "$c"
		[ -z "$output" ]
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
		'git notes --ref revisao remove HEAD' 'git update-ref refs/notes/revisao HEAD' \
		'git notes --ref=revisao "add" -m x HEAD' 'git notes --re=revisao add -m x' \
		'GIT_NOTES_REF=refs/notes/revisao git notes add -m x' \
		'git -c core.notesRef=refs/notes/revisao notes add -m x' \
		'git update-ref -d refs/notes/revisao'; do
		run guarda "$c"
		recusa
	done
	for c in 'git notes --ref=revisao show HEAD' 'git notes --ref=revisao list' 'git notes add -m x' \
		'GIT_NOTES_REF=refs/notes/outra git notes add -m x'; do
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
		'git config core.hooksPath /dev/null' 'git config --unset core.hookspath' \
		'git config core.hooksPath "x --get"' 'git config --unset-a core.hooksPath' \
		'git config --global --remove-section core' 'git config rename-section core x' \
		'git config -t path core.hooksPath /x' 'git config -tpath core.hooksPath /x'; do
		run guarda "$c"
		recusa
	done
	for c in 'git config core.hooksPath' 'git config --get core.hooksPath' \
		'git config core.hooksPath 2>/dev/null || echo nenhum' \
		'git config core.hooksPath 2>&1' 'git config core.hooksPath > /tmp/x' \
		'git config core.hooksPath 2>"/dev/null"' 'git config --get -- core.hooksPath'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "mexer em hook.* é recusado, também entre aspas" {
	for c in 'git -c hook.revisao-push.enabled=false push' \
		'git -c "hook.revisao-push.enabled=false" push' \
		'git -cHook.revisao-push.enabled=false push' \
		'git --config-env=hook.revisao-push.enabled=X push' \
		'git config --global hook.assunto-merge.enabled false' \
		'git -C ~/x config hook.revisao-commit.command true' \
		'git config hook.revisao-push.command "echo --show"' \
		'git config set hook.revisao-push.enabled false' \
		'git config unset hook.revisao-push.command' \
		'git config --unset-all hook.revisao-push.event' \
		'git config --global --remove-section hook.revisao-push' \
		'git config --global -e' \
		'git config --global --unset-a hook.revisao-push.event' \
		'git config --global --remove-s hook.revisao-push' \
		"git -c 'hook.revisao-push.enabled=false' -c 'x.y=a;b' push" \
		"git config hook.revisao-push.command ';'" \
		'git config 2>/dev/null hook.revisao-push.enabled false' \
		'git config --global include.path /tmp/sem-hooks' \
		'git config -t bool hook.revisao-push.enabled false' \
		'git config -t string alias.p "push --no-verify"'; do
		run guarda "$c"
		recusa
	done
}

@test "o git dentro de prefixo, palavra do shell, aspas ou eval também se confere" {
	for c in "'git' commit -n -m x" 'g\it commit -n -m x' "git 'commit' -n" \
		'/usr/bin/git commit -n -m x' 'sudo git commit -n -m x' \
		'timeout 60 git commit -n -m x' 'nice -n 5 git commit -n -m x' \
		'command -- git commit -n -m x' 'time -p git commit -n -m x' \
		'exec -a g git commit -n -m x' 'env -S "git commit -n -m x"' \
		"env -S'git commit -n -m x'" "env --split-string='git commit -n -m x'" \
		'if git commit -n -m x; then echo ok; fi' '{ git commit -n -m x; }' \
		'for r in a b; do git -C $r commit -n -m x; done' '! git commit -n -m x' \
		'echo `git commit -n -m x`' 'echo "$(git commit -n -m x)"' \
		"eval 'git commit -n -m x'" "bash <<< 'git commit -n -m x'" \
		"bash <<<'git commit -n -m x'" "env bash <<< 'git commit -n -m x'" \
		"command eval 'git commit -n -m x'" 'bash -c -- "git commit -n -m x"' \
		'git config -ze' 'git config -zf /tmp/config core.hooksPath z' \
		"git config \$'core.hooksPath' /tmp/hooks" "git config core.hooksPath '>log'" \
		'sudo --user root git commit -n -m x' '/usr/bin/env git commit -n -m x' \
		'command time --format %E git commit -n -m x' \
		"git -c alias.x='commit' x -n" "git -c alias.x='!git commit' x -n" \
		'git commit>/dev/null -n' 'git commit -m x 2>&1 -n' 'git commit &>/dev/null -n -m x' \
		"bash -c 'git commit -n -m x' <<< 'echo ok'" \
		"echo \"\$(printf ')'; git commit -n -m x)\"" \
		"git config \$'core.\\x68ooksPath' /tmp/hooks" "git \$'co\\x6dmit' -n" \
		"git -c alias.x='commit -n -m x' x" 'git -c alias.p="!git commit --no-verify" p'; do
		run guarda "$c"
		recusa
	done
	for c in "echo 'ok; git commit -n'" "git commit -m 'ok; git commit -n'" \
		'# exemplo; git commit -n' 'echo "git commit -n -m x"' 'make check 2>&1 | tail' \
		'echo a &>/dev/null; git status' 'sleep 1 & git status'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "hook.* e push --no-verify se conferem por prefixo, heredoc, aspas e eval" {
	for c in "'git' config hook.x z" "git 'config' hook.x z" 'sudo git config --system hook.x z' \
		'timeout 60 git config --global hook.x z' 'env -S "git config hook.x z"' \
		"env -S'git push --no-verify'" 'echo "$(git config hook.x z)"' \
		"eval 'git config hook.x z'" "bash <<< 'git config hook.x z'" \
		'git config -zf /tmp/config hook.x z' "git config hook.x '>log'" \
		"git -c alias.x='config' x hook.y z" "git -c alias.x='config hook.x z' x" \
		'git -c alias.p="!git push --no-verify" p' 'git push --no-verify>/dev/null' \
		$'bash <<\'EOF\'\ngit config hook.x z\nEOF' $'git \\\nconfig hook.x z' \
		$'cat <<\'EOF\'; git push --no-verify\ntexto\nEOF' \
		$'cat <<\'EOF\' && git config hook.x z\ntexto\nEOF'; do
		run guarda "$c"
		recusa
	done
	for c in $'cat <<\'END-OF\'\n$(git config hook.x z)\nEND-OF' \
		$'cat <<EOF\ngit config hook.x z\nEOF' "echo '\$(git config hook.x z)'" \
		'git push origin main # --no-verify' "git -c alias.x='config hook.y z' status" \
		'git config --get hook.x # --unset' 'git config hook.x # description' \
		'git config -f/tmp/settings --get hook.x' 'echo "git config hook.x z"'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "ler hook.* passa, na forma nova e na antiga" {
	for c in 'git config --get hook.revisao-push.command' \
		'git config hook.revisao-push.command' \
		'git config get hook.revisao-push.command' \
		'git config --show-origin --get-regexp ^hook\.' \
		'git config --list --show-origin' 'git config list' \
		'git log --grep hook.x' 'git config user.name Fulano' \
		'git config --ge hook.revisao-push.command' \
		'git commit -m "nota: git config hook.x y; git push --no-verify"'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "push, merge e pull com --no-verify são recusados, também abreviados ou num alias; o comum passa" {
	for c in 'git push --no-verify' 'git push origin main --no-verify' \
		'git push --no-verif' 'git push --no-veri origin t' \
		'cd ~/x && git -C ~/y push --no-verify origin t' \
		'git -c x.y=1 push --no-verify' "'git' push --no-verify" \
		"git commit -m 'fix; hooks' --no-verify" 'timeout 60 git push --no-verify' \
		'git push 2>&1 --no-verify' 'git merge --no-verify t' 'git merge --no-verif t' \
		'git pull --no-verify' 'git config --global alias.p "push --no-verify"' \
		"git config set alias.c '!git commit -n'" 'git config alias.h "config hook.x z"' \
		'git push -o -- --no-verify origin main' 'git merge -m -- --no-verify t' \
		'git pull -j --no-verify' 'git pull --jobs --no-verify'; do
		run guarda "$c"
		recusa
	done
	for c in 'git push' 'git push -n origin main' 'git push -u origin t' \
		'git push origin -- --no-verify' 'git merge --no-ff -m "Junta o ramo t: x" t' \
		'git config --global alias.st status' 'git config --get alias.p' \
		'git push -o --no-verify origin main' 'git push -o ci.skip origin main'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "tirar CLAUDECODE do ambiente é recusado" {
	for c in 'CLAUDECODE= git commit -m x' 'unset CLAUDECODE; git commit -m x' \
		'env -u CLAUDECODE git commit -m x' 'env --unset=CLAUDECODE git commit' \
		'env -i PATH=/usr/bin git commit -m x' 'export CLAUDECODE=0' \
		'/usr/bin/env -u CLAUDECODE git commit -m x' "env -S 'CLAUDECODE= git commit -m x'" \
		'nice unset CLAUDECODE' 'export -n CLAUDECODE' 'CLAUDECODE=; git commit -m x' \
		'export -n CLAUDECODE=1; git commit -m x' 'declare +x CLAUDECODE=1'; do
		run guarda "$c"
		recusa
	done
	for c in 'CLAUDECODE=1 bats x.bats' 'unset DEBUG; git commit -m x' 'export EDITOR=vim'; do
		run guarda "$c"
		[ -z "$output" ]
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
		"gh api graphql -f query='mutation { enablePullRequestAutoMerge(input: {pullRequestId: \"x\"}) { clientMutationId } }'" \
		"'gh' pr merge 12" 'timeout 5 gh pr merge 1' 'if gh pr merge 1; then :; fi' \
		'gh pr -R o/r merge 3' "gh alias set m 'pr merge'"; do
		run guarda "$c"
		recusa
	done
	for c in 'gh pr view 12' "gh alias set co 'pr checkout'" 'gh api repos/o/r/pulls/3'; do
		run guarda "$c"
		[ -z "$output" ]
	done
}

@test "git revisao excecao pergunta ao autor; pronto e pendente passam" {
	run guarda 'git revisao excecao -m "o autor aceitou"'
	pergunta
	run guarda '~/.local/bin/git-revisao excecao -m x'
	pergunta
	run guarda 'git "revisao" excecao -m x'
	pergunta
	run guarda "command git 'revisao' 'excecao' -m x"
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
