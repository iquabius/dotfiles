#!/usr/bin/env bats
# Testes do git-revisao, que mora ao lado deste arquivo. Cada teste cria um
# repositório e um remoto descartáveis, com bin/ como caminho de código; os
# hooks entram pelo .git/hooks do repositório, e não pela configuração
# global, para a suíte rodar também em git anterior ao 2.54.

bats_require_minimum_version 1.5.0

SCRIPT="${GIT_REVISAO_SCRIPT:-$BATS_TEST_DIRNAME/git-revisao}"

setup() {
	export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
	export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
	unset CLAUDECODE
	cd "$BATS_TEST_TMPDIR"
	git init -q --bare remoto.git
	git init -q -b main repo
	cd repo
	git remote add origin ../remoto.git
	printf '#!/bin/sh\nexec "%s" pre-push "$@"\n' "$SCRIPT" >.git/hooks/pre-push
	printf '#!/bin/sh\nexec "%s" pre-commit\n' "$SCRIPT" >.git/hooks/pre-commit
	chmod +x .git/hooks/pre-push .git/hooks/pre-commit
	# "git revisao" acha o git-revisao no PATH, como na máquina; um alias
	# com ! rodaria da raiz e esconderia o diretório de onde se chama.
	mkdir -p "$BATS_TEST_TMPDIR/bin"
	ln -s "$SCRIPT" "$BATS_TEST_TMPDIR/bin/git-revisao"
	export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
	mkdir -p .config bin
	printf '# código\n.config/revisao\nbin/\n:!bin/*.md\n' >.config/revisao
	echo texto >leia.org
	git add . && git commit -qm raiz
	git revisao excecao -m "raiz do teste" >/dev/null
	git push -q -u origin main
}

# muda <arquivo> [mensagem] — acrescenta uma linha e commita.
muda() {
	mkdir -p "$(dirname "$1")"
	echo "$RANDOM" >>"$1"
	git add "$1"
	git commit -qm "${2:-$1}"
}

@test "texto no main passa sem marca" {
	muda leia.org
	muda bin/leia.md
	run git push origin main
	[ "$status" -eq 0 ]
}

@test "código no main sem marca é recusado, com o commit e o arquivo" {
	muda leia.org
	muda bin/x "acrescenta x"
	run git push origin main
	[ "$status" -ne 0 ]
	[[ $output == *"código sem revisão no main"* ]]
	[[ $output == *"acrescenta x"* ]]
	[[ $output == *"bin/x"* ]]
	[[ $output != *leia.org* ]]
}

@test "ramo marcado como pronto e juntado por fast-forward passa" {
	git switch -qc tarefa
	muda bin/x
	muda bin/x "corrige o achado da revisão"
	run git revisao pronto
	[ "$status" -eq 0 ]
	[[ $output == *"cobre 2 commit(s)"* ]]
	git switch -q main
	git merge -q --ff-only tarefa
	run git push origin main
	[ "$status" -eq 0 ]
}

@test "marca de ramo já enviado a outro ramo do remoto continua valendo no main" {
	git switch -qc tarefa
	muda bin/x
	git revisao pronto
	git push -q origin tarefa
	git switch -q main
	git merge -q --ff-only tarefa
	run git push origin main
	[ "$status" -eq 0 ]
}

@test "commit depois da marca fica sem revisão" {
	git switch -qc tarefa
	muda bin/x
	git revisao pronto
	muda bin/x "depois da revisão"
	git switch -q main
	git merge -q --ff-only tarefa
	run git push origin main
	[ "$status" -ne 0 ]
	[[ $output == *"depois da revisão"* ]]
}

@test "main andou: merge --no-ff de ramo marcado passa, mesmo com o arquivo juntado sozinho" {
	seq 1 20 >bin/n
	git add bin/n && git commit -qm n
	git revisao excecao -m "base do teste"
	git switch -qc tarefa
	sed -i 's/^20$/vinte/' bin/n && git commit -qam "fim"
	git revisao pronto
	git switch -q main
	sed -i 's/^1$/um/' bin/n && git commit -qam "começo"
	git revisao pronto
	git merge -q --no-ff tarefa -m "junta a tarefa"
	run git push origin main
	[ "$status" -eq 0 ]
}

@test "merge que resolve conflito no código precisa de marca própria" {
	echo 1 >bin/n
	git add bin/n && git commit -qm n
	git revisao pronto
	git switch -qc tarefa
	echo ramo >bin/n && git commit -qam ramo
	git revisao pronto
	git switch -q main
	echo main >bin/n && git commit -qam main
	git revisao pronto
	run git merge -q --no-ff tarefa
	echo resolvido >bin/n && git commit -qam "junta a tarefa"
	run git push origin main
	[ "$status" -ne 0 ]
	[[ $output == *"junta a tarefa"* ]]
	git revisao pronto
	run git push origin main
	[ "$status" -eq 0 ]
}

@test "commit de código feito no main antes do ramo não entra na marca do ramo" {
	muda bin/x "direto no main"
	git switch -qc tarefa
	muda bin/y
	git revisao pronto
	git switch -q main
	git merge -q --ff-only tarefa
	run git push origin main
	[ "$status" -ne 0 ]
	[[ $output == *"direto no main"* ]]
	[[ $output != *"bin/y"* ]]
}

@test "marca na linha do main cobre o que o remoto ainda não tem" {
	muda bin/x um
	muda bin/x dois
	run git revisao excecao -m "anterior à revisão"
	[[ $output == *"cobre 2 commit(s)"* ]]
	run git push origin main
	[ "$status" -eq 0 ]
}

@test "commits reescritos com as mesmas árvores herdam a marca" {
	git switch -qc tarefa
	muda bin/x
	muda bin/y
	git revisao pronto
	# Como um rebase que só refaz as datas: só a data de commit muda, e os
	# shas com ela.
	GIT_COMMITTER_DATE=2020-01-01T10:00:00 git rebase -q --force-rebase main
	git switch -q main
	git merge -q --ff-only tarefa
	run git push origin main
	[ "$status" -eq 0 ]
}

@test "commit reescrito com outro código não herda a marca" {
	git switch -qc tarefa
	muda bin/x
	git revisao pronto
	echo mais >>bin/x && git commit -q --amend --no-edit -a
	git switch -q main
	git merge -q --ff-only tarefa
	run git push origin main
	[ "$status" -ne 0 ]
	[[ $output == *"bin/x"* ]]
}

@test "commit reaplicado sobre outro código não herda a marca" {
	git switch -qc tarefa
	muda bin/x "da tarefa"
	git revisao pronto
	git switch -q main
	muda bin/y "andou"
	git revisao pronto
	git cherry-pick tarefa >/dev/null
	run git push origin main
	[ "$status" -ne 0 ]
	[[ $output == *"da tarefa"* ]]
	[[ $output != *"andou"* ]]
}

@test "commit que chega à árvore revisada por outro diff não herda a marca" {
	echo 1 >bin/n
	git add bin/n && git commit -qm n
	git revisao pronto
	git switch -qc tarefa
	echo 2 >bin/n && git commit -qam "de 1 a 2"
	git revisao pronto
	git switch -q main
	echo 3 >bin/n && git commit -qam "de 1 a 3"
	echo 2 >bin/n && git commit -qam "de 3 a 2"
	run git push origin main
	[ "$status" -ne 0 ]
	[[ $output == *"de 3 a 2"* ]]
}

@test "merge reescrito com a mesma resolução herda a marca" {
	echo 1 >bin/n
	git add bin/n && git commit -qm n
	git revisao pronto
	git switch -qc tarefa
	echo ramo >bin/n && git commit -qam ramo
	git revisao pronto
	git switch -q main
	echo main >bin/n && git commit -qam main
	git revisao pronto
	run git merge -q --no-ff tarefa
	echo resolvido >bin/n && git commit -qam "junta a tarefa"
	git revisao pronto
	GIT_COMMITTER_DATE=2020-01-01T10:00:00 git commit -q --amend --no-edit
	run git push origin main
	[ "$status" -eq 0 ]
}

@test "reescrever só a mensagem do que o remoto já tem herda a marca no push forçado" {
	muda bin/x "mensagem antiga"
	git revisao pronto
	git push -q origin main
	# Como o rebase que só refaz mensagens: o original, com a marca, fica no
	# main do remoto, e o push forçado leva a cópia.
	git commit -q --amend -m "mensagem nova"
	run git revisao pendente
	[ "$status" -eq 0 ]
	run git push --force-with-lease origin main
	[ "$status" -eq 0 ]
	# Mudar o código no reescrito pede marca nova, como fora do remoto.
	echo mais >>bin/x && git commit -q --amend --no-edit -a
	run git revisao pendente
	[ "$status" -eq 1 ]
	[[ $output == *"bin/x"* ]]
	run git push --force-with-lease origin main
	[ "$status" -ne 0 ]
}

@test "cherry-pick de commit revisado em cima do revert dele passa sem marca nova" {
	muda bin/x "revisado"
	git revisao pronto
	git push -q origin main
	git revert --no-edit HEAD >/dev/null
	git revisao excecao -m "desfaz o revisado" >/dev/null
	git push -q origin main
	# O mesmo diff sobre a mesma árvore, ainda que o pai seja outro commit
	# (o revert) e o original já esteja no main do remoto, atrás do que o
	# push leva: é o que a revisão viu.
	git cherry-pick HEAD~1 >/dev/null
	run git revisao pendente
	[ "$status" -eq 0 ]
	run git push origin main
	[ "$status" -eq 0 ]
}

# teste <comando> — declara o teste no .config/revisao e o leva ao main.
teste() {
	printf 'teste: %s\n' "$1" >>.config/revisao
	git commit -qam "teste: $1"
	git revisao excecao -m "teste do teste" >/dev/null
}

@test "pronto roda o teste declarado e não marca quando ele falha" {
	teste 'test ! -e bin/quebrado'
	git switch -qc tarefa
	muda bin/quebrado
	run git revisao pronto
	[ "$status" -ne 0 ]
	[[ $output == *"o teste falhou"* ]]
	run git notes --ref=revisao show HEAD
	[ "$status" -ne 0 ]
	git rm -q bin/quebrado && git commit -qm conserta
	run git revisao pronto
	[ "$status" -eq 0 ]
	[[ $output == *"pronto, cobre 2 commit(s)"* ]]
}

@test "o teste recebe a base e a ponta, e roda da raiz" {
	teste 'echo "$GIT_REVISAO_BASE $GIT_REVISAO_PONTA" >.git/rodou'
	git switch -qc tarefa
	muda bin/x
	cd bin
	git revisao pronto
	[ "$(cat ../.git/rodou)" = "$(git merge-base main HEAD) $(git rev-parse HEAD)" ]
}

@test "sem código no intervalo, o teste roda e decide" {
	teste 'touch .git/rodou'
	git switch -qc tarefa
	muda leia.org
	git revisao pronto
	[ -e .git/rodou ]
}

@test "com teste, pronto só marca o HEAD sem código fora do commit" {
	teste 'true'
	git switch -qc tarefa
	muda bin/x
	muda bin/y
	run git revisao pronto HEAD~1
	[ "$status" -ne 0 ]
	[[ $output == *"HEAD"* ]]
	echo mais >>bin/x
	run git revisao pronto
	[ "$status" -ne 0 ]
	[[ $output == *"bin/x"* ]]
	git checkout -q bin/x
	# Nem a configuração que esconde os arquivos novos do status os esconde.
	git config status.showUntrackedFiles no
	touch bin/novo
	run git revisao pronto
	[ "$status" -ne 0 ]
	[[ $output == *"bin/novo"* ]]
	rm bin/novo
	echo rascunho >>leia.org
	run git revisao pronto
	[ "$status" -eq 0 ]
}

@test "ramo que tira a linha do teste roda a do main" {
	teste 'test ! -e bin/quebrado'
	git switch -qc tarefa
	muda bin/quebrado
	sed -i '/^teste:/d' .config/revisao
	git commit -qam "tira o teste"
	run git revisao pronto
	[ "$status" -ne 0 ]
	[[ $output == *"o teste falhou"* ]]
}

@test "exceção não roda o teste" {
	teste 'false'
	muda bin/x
	run git revisao excecao -m "o autor leva sem o teste"
	[ "$status" -eq 0 ]
}

@test "exceção exige motivo e o grava na nota" {
	muda bin/x
	run git revisao excecao
	[ "$status" -eq 2 ]
	run git revisao excecao -m "  "
	[ "$status" -eq 2 ]
	git revisao excecao -m "o autor aceitou o achado"
	run git notes --ref=revisao show HEAD
	[[ $output == *"revisao: exceção"* ]]
	[[ $output == *"motivo: o autor aceitou o achado"* ]]
}

@test "nota com veredito desconhecido não vale" {
	muda bin/x
	git notes --ref=revisao add -m "revisao: talvez" HEAD
	run git push origin main
	[ "$status" -ne 0 ]
}

@test "marca de commit que o gc levou não derruba o pre-push nem cobre além da base" {
	muda bin/x "reescrito"
	git revisao pronto
	git reset -q --hard HEAD~1
	git reflog expire --expire=now --all && git gc -q --prune=now
	muda bin/x "sem marca"
	run git push origin main
	[ "$status" -ne 0 ]
	[[ $output == *"sem marca"* ]]
	[[ $output != *"falhou"* ]]
	# Base que não existe: a marca não vale, em vez de valer desde a raiz.
	printf 'revisao: pronto\nbase: %s\n' "$(printf 'x' | git hash-object --stdin)" |
		git notes --ref=revisao add -f -F - HEAD
	run git push origin main
	[ "$status" -ne 0 ]
}

@test "estreitar a lista não tira da revisão o que ela cobria no remoto" {
	printf '.config/revisao\n' >.config/revisao
	git add .config/revisao
	muda bin/x "escondido"
	run git push origin main
	[ "$status" -ne 0 ]
	[[ $output == *"escondido"* ]]
	[[ $output == *"bin/x"* ]]
}

@test "repositório sem .config/revisao fica de fora" {
	git rm -q .config/revisao && git commit -qm "sai da revisão"
	git revisao excecao -m "sai"
	git push -q origin main
	muda bin/x
	run git push origin main
	[ "$status" -eq 0 ]
}

@test "código em outro ramo do remoto passa; levá-lo ao main, não" {
	git switch -qc tarefa
	muda bin/x
	run git push origin tarefa
	[ "$status" -eq 0 ]
	run git push origin tarefa:main
	[ "$status" -ne 0 ]
	# Nem pelo merge, num remoto que ainda não tem main.
	git push -q origin :main
	git switch -q main
	git merge -q --ff-only tarefa
	run git push origin main
	[ "$status" -ne 0 ]
	[[ $output == *"bin/x"* ]]
}

@test "o master conta como main" {
	git branch -m main master
	muda bin/x
	run git push origin master
	[ "$status" -ne 0 ]
	[[ $output == *"sem revisão no master"* ]]
}

@test "repositório SHA-256: apagar o main no remoto passa" {
	cd "$BATS_TEST_TMPDIR"
	git init -q --bare --object-format=sha256 remoto256.git
	git init -q -b main --object-format=sha256 repo256
	cd repo256
	cp ../repo/.git/hooks/pre-push .git/hooks/
	git remote add origin ../remoto256.git
	mkdir .config && echo bin/ >.config/revisao
	git add . && git commit -qm raiz
	git push -q origin main
	run git push origin :main
	[ "$status" -eq 0 ]
}

@test "as notas da revisão não vão para o remoto" {
	muda bin/x
	git revisao pronto
	run git push origin refs/notes/revisao
	[ "$status" -ne 0 ]
	[[ $output == *"fica no clone"* ]]
	run git push origin refs/notes/revisao:refs/notes/outra
	[ "$status" -ne 0 ]
	run git push origin "$(git rev-parse refs/notes/revisao):refs/heads/notas"
	[ "$status" -ne 0 ]
	[ -z "$(git ls-remote origin 'refs/notes/*' refs/heads/notas)" ]
}

@test "pendente lista o código sem marca e sai com 1" {
	muda bin/x "sem marca"
	run git revisao pendente
	[ "$status" -eq 1 ]
	[[ $output == *"sem marca"* ]]
	git revisao pronto
	run git revisao pendente
	[ "$status" -eq 0 ]
	[[ $output == *"nada pendente"* ]]
}

@test "pendente de um subdiretório vê os caminhos a partir da raiz" {
	muda bin/x
	cd bin
	run git revisao pendente
	[ "$status" -eq 1 ]
	[[ $output == *"bin/x"* ]]
}

@test "pre-commit: agente no main com código é recusado; texto e ramo passam" {
	export CLAUDECODE=1
	echo x >bin/x && git add bin/x
	run git commit -qm x
	[ "$status" -ne 0 ]
	[[ $output == *"commit de agente no main"* ]]
	[[ $output == *"bin/x"* ]]
	git reset -q
	muda leia.org
	git switch -qc tarefa
	run muda bin/x
	[ "$status" -eq 0 ]
}

@test "pre-commit: commit -- arquivo e commit -a também são vistos" {
	echo x >bin/x && git add bin/x
	git commit -qm x
	export CLAUDECODE=1
	echo y >>bin/x
	run git commit -qm y -- bin/x
	[ "$status" -ne 0 ]
	run git commit -qam y
	[ "$status" -ne 0 ]
}

@test "pre-commit: sem CLAUDECODE, a pessoa commita no main" {
	run muda bin/x
	[ "$status" -eq 0 ]
}

@test "pre-commit: concluir um merge com conflito no main passa" {
	echo 1 >bin/n && git add bin/n && git commit -qm n
	git switch -qc tarefa
	echo ramo >bin/n && git commit -qam ramo
	git switch -q main
	echo main >bin/n && git commit -qam main
	export CLAUDECODE=1
	run git merge -q --no-ff tarefa
	echo resolvido >bin/n && git add bin/n
	run git commit -qm "junta a tarefa"
	[ "$status" -eq 0 ]
}
