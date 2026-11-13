#!/usr/bin/env bats
# Testes do .githooks/pre-commit.
#
# Cada teste monta um repositório de brinquedo em $BATS_TEST_TMPDIR, põe no
# índice o que quer conferir e roda o hook ali, como o git o rodaria antes
# do commit. A conta de exemplo vai sem a barra final ($H e $U), que o hook
# não pega, para esta suíte passar por ele.

# PRE_COMMIT_SCRIPT troca o hook testado (útil para conferir, com uma cópia
# sabotada, que o teste de fato pega a falha).
SCRIPT="${PRE_COMMIT_SCRIPT:-$BATS_TEST_DIRNAME/../.githooks/pre-commit}"

H=/home/fulano
U=/Users/fulano

setup() {
	export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
	export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
	cd "$BATS_TEST_TMPDIR"
	git init -q -b main r
	cd r
	printf 'um\ndois\nantigo %s/x\ntrês\nquatro\ncinco\n' "$H" >velho.txt
	git add .
	git commit -qm raiz
}

@test "linha nova com home de pessoa recusa e diz o arquivo" {
	echo "caminho $H/projeto" >novo.txt
	git add novo.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *novo.txt* ]]
	[[ $output == *"$H/projeto"* ]]
}

@test "conta de sistema e linha sem home passam" {
	printf '/home/linuxbrew/.linuxbrew/bin\n/Users/runner/work\n$HOME/x\n' >novo.txt
	git add novo.txt
	run "$SCRIPT"
	[ "$status" -eq 0 ]
}

@test "conta de sistema não isenta a outra conta da mesma linha" {
	echo "/home/runner/x e $H/y" >novo.txt
	git add novo.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
}

@test "conta de sistema não cola as pontas num caminho novo" {
	printf '/ho/home/root/me/fulano/x\n/home/root/home/root/x\n' >novo.txt
	git add novo.txt
	run "$SCRIPT"
	[ "$status" -eq 0 ]
}

@test "conta de sistema não esconde a conta que vem depois dela" {
	echo "/home/runner$H/y" >novo.txt
	git add novo.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
}

@test "linha antiga num arquivo mudado não conta" {
	echo seis >>velho.txt
	git add velho.txt
	run "$SCRIPT"
	[ "$status" -eq 0 ]
}

@test "linha removida com home não conta" {
	sed -i '/antigo/d' velho.txt
	git add velho.txt
	run "$SCRIPT"
	[ "$status" -eq 0 ]
}

@test "arquivo renomeado com linha nova de home recusa" {
	git mv velho.txt renomeado.txt
	echo "novo $H/y" >>renomeado.txt
	git add renomeado.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *renomeado.txt* ]]
	[[ $output == *"$H/y"* ]]
}

@test "arquivo renomeado não conta a linha antiga como nova" {
	git mv velho.txt renomeado.txt
	echo seis >>renomeado.txt
	git add renomeado.txt
	run "$SCRIPT"
	[ "$status" -eq 0 ]
}

@test "renomeado com muita mudança não conta a linha antiga como nova" {
	git mv velho.txt renomeado.txt
	seq 1 20 >>renomeado.txt
	git add renomeado.txt
	run "$SCRIPT"
	[ "$status" -eq 0 ]
}

@test "linha movida para outro arquivo não conta" {
	grep antigo velho.txt >outro.txt
	sed -i '/antigo/d' velho.txt
	git add velho.txt outro.txt
	run "$SCRIPT"
	[ "$status" -eq 0 ]
}

@test "linha movida e copiada conta a cópia" {
	grep antigo velho.txt >outro.txt
	grep antigo velho.txt >mais.txt
	sed -i '/antigo/d' velho.txt
	git add velho.txt outro.txt mais.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
}

@test "linha copiada para outro arquivo conta" {
	grep antigo velho.txt >outro.txt
	git add outro.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *outro.txt* ]]
}

@test "nome com espaço chega inteiro, sem o tab do cabeçalho" {
	echo "caminho $U/z" >'com espaço.txt'
	git add 'com espaço.txt'
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *$'  com espaço.txt\n'* ]]
}

@test "nome que o git põe entre aspas sai com o nome real" {
	echo "caminho $H/q" >'z"q.txt'
	git add 'z"q.txt'
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *$'  z"q.txt\n'* ]]
}

@test "nome com barra invertida e letra sai com o nome real, sem aspas" {
	echo "caminho $H/q" >'z\tq.txt'
	git add 'z\tq.txt'
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *$'\n  z\\tq.txt\n'* ]]
}

@test "nome com aspas e espaço sai sem a aspa e o tab do fim" {
	echo "caminho $H/r" >'a "b c.txt'
	git add 'a "b c.txt'
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *$'  a "b c.txt\n'* ]]
}

@test "nome com caractere de controle sai como o git o escreve, com aspas" {
	echo "caminho $H/r" >$'t\tb "c.txt'
	git add $'t\tb "c.txt'
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *$'  "t\\tb \\"c.txt"\n'* ]]
}

@test "conteúdo de submódulo não entra, com diff.submodule=diff" {
	git init -q -b main "$BATS_TEST_TMPDIR/sub"
	echo "x $H/s" >"$BATS_TEST_TMPDIR/sub/a"
	git -C "$BATS_TEST_TMPDIR/sub" add a
	git -C "$BATS_TEST_TMPDIR/sub" commit -qm s
	git -c protocol.file.allow=always submodule add -q "$BATS_TEST_TMPDIR/sub" sm
	git config diff.submodule diff
	run "$SCRIPT"
	[ "$status" -eq 0 ]
}

@test "conteúdo que começa com ++ não passa por cabeçalho" {
	printf '++ b/x %s/w\n' "$H" >mais.txt
	git add mais.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *"$H/w"* ]]
}

@test "binário com home recusa, com o NUL trocado por ?" {
	printf '\0%s/b\n' "$H" >bin.dat
	git add bin.dat
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *bin.dat* ]]
	[[ $output == *"?$H/b"* ]]
}

# O bash avisa do NUL que o $(...) descarta; o dash, não. Por isso estes
# rodam o hook pelo bash, seja qual for o sh da máquina.
@test "binário com home recusa no bash, sem aviso de NUL" {
	printf '\0%s/b\n' "$H" >bin.dat
	git add bin.dat
	run bash "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output != *"null byte"* ]]
}

@test "binário sem home passa no bash, sem aviso de NUL" {
	printf '\0\1\2/home/\0fulano/x\n' >bin.dat
	git add bin.dat
	run bash "$SCRIPT"
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "binário sem home passa, sem colar as pontas do NUL" {
	printf '\0\1\2/home/\0fulano/x\n' >bin.dat
	git add bin.dat
	run "$SCRIPT"
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "recusa não manda ao terminal os bytes de controle da linha" {
	printf '\033[31m %s/e\r\n' "$H" >cor.txt
	git add cor.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *"?[31m $H/e?"* ]]
	[[ $output != *$'\033'* ]]
}

@test "awk que falha recusa o commit" {
	echo "caminho $H/f" >novo.txt
	git add novo.txt
	mkdir "$BATS_TEST_TMPDIR/bin"
	printf '#!/bin/sh\nexit 2\n' >"$BATS_TEST_TMPDIR/bin/awk"
	chmod +x "$BATS_TEST_TMPDIR/bin/awk"
	PATH="$BATS_TEST_TMPDIR/bin:$PATH" run "$SCRIPT"
	[ "$status" -ne 0 ]
}

@test "textconv do .gitattributes não esconde o conteúdo cru" {
	echo 'bin.dat diff=conv' >.gitattributes
	git config diff.conv.textconv 'sed s,/,,g'
	printf '\0%s/b\n' "$H" >bin.dat
	git add .gitattributes bin.dat
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *"$H/b"* ]]
}

@test "atributo -diff do .git/info/attributes não esconde a linha" {
	echo 'novo.txt -diff' >.git/info/attributes
	echo "caminho $H/d" >novo.txt
	git add novo.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *"$H/d"* ]]
}

@test "symlink novo com alvo de home recusa" {
	ln -s "$H/alvo" lk
	git add lk
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *'  lk'* ]]
}

@test "arquivo que vira symlink com alvo de home recusa" {
	git rm -q velho.txt
	ln -s "$H/alvo" velho.txt
	git add velho.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *'  velho.txt'* ]]
}

@test "configuração de prefixo do diff não esconde o arquivo" {
	git config diff.noprefix true
	git config diff.mnemonicPrefix true
	echo "caminho $H/p" >novo.txt
	git add novo.txt
	run "$SCRIPT"
	[ "$status" -eq 1 ]
	[[ $output == *'  novo.txt'* ]]
}
