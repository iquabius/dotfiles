#!/usr/bin/env bats
# Testes do forca-no-patch, ao lado deste arquivo. Cada teste fornece um
# diff e confere os achados, as linhas e os códigos de saída.
# FORCA_NO_PATCH_SCRIPT aponta para a cópia sabotada, sem mudar a suíte.

bats_require_minimum_version 1.5.0

SCRIPT="${FORCA_NO_PATCH_SCRIPT:-$BATS_TEST_DIRNAME/forca-no-patch}"

setup() {
	cd "$BATS_TEST_TMPDIR"
}

pela_entrada() {
	"$SCRIPT" "$@" <patch
}

@test "item de lista tirado (-- Nunca) dá uma força e três permissões" {
	cat >patch <<'EOF'
diff --git a/skill.md b/skill.md
--- a/skill.md
+++ b/skill.md
@@ -10 +10,3 @@
-- Nunca relate uma preferência como achado: sem citação, sem cartão.
+- Nunca relate uma preferência como fato. Sem fonte, escreva `palpite`
+  em Cita, com grau `[Julgamento]` para um juízo que se pode apontar ou
+  `[Afirmado]` se não houver respaldo.
EOF
	run "$SCRIPT" patch
	[ "$status" -eq 1 ]
	esperado=$(cat <<'EOF'
skill.md:10: força: - Nunca relate uma preferência como achado: sem citação, sem cartão.
skill.md:10: permissão: - Nunca relate uma preferência como fato. Sem fonte, escreva `palpite`
skill.md:11: permissão:   em Cita, com grau `[Julgamento]` para um juízo que se pode apontar ou
skill.md:12: permissão:   `[Afirmado]` se não houver respaldo.
EOF
	)
	[ "$output" = "$esperado" ]
}

@test "cabeçalhos --- a/ e --- /dev/null não viram achados" {
	cat >patch <<'EOF'
diff --git a/Nunca.md b/Nunca.md
--- a/Nunca.md
+++ b/Nunca.md
@@ -1 +1 @@
-texto
+outro texto
diff --git a/jamais.md b/jamais.md
--- /dev/null
+++ b/jamais.md
@@ -0,0 +1 @@
+texto
EOF
	run "$SCRIPT" patch
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "linha idêntica que volta no hunk, sem espaços finais, não é retirada" {
	{
		printf '%s\n' '--- a/teste.bats' '+++ b/teste.bats' '@@ -1,2 +1,2 @@'
		printf '%s\n' '-Nunca retire a regra.   ' '-assert resultado'
		printf '%s\n' '+assert resultado   ' '+Nunca retire a regra.'
	} >patch
	run "$SCRIPT" patch
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "asserção bats retirada usa a linha velha e reconhece cada forma" {
	cat >patch <<'EOF'
--- a/verifica.bats
+++ b/verifica.bats
@@ -10,7 +10,0 @@
-[[ $output != *$'\e['* ]]
-assert resultado
-refute erro
-[ "$status" = 0 ]
-expect sucesso
-resultado -eq esperado
-resultado -ne outro
EOF
	run "$SCRIPT" --so asserção patch
	[ "$status" -eq 1 ]
	[ "${#lines[@]}" -eq 7 ]
	[ "${lines[0]}" = "verifica.bats:10: asserção: [[ \$output != *\$'\e['* ]]" ]
	[[ ${lines[1]} == *":11: asserção: assert resultado" ]]
	[[ ${lines[2]} == *":12: asserção: refute erro" ]]
	[[ ${lines[3]} == *":13: asserção: [ "* ]]
	[[ ${lines[4]} == *":14: asserção: expect sucesso" ]]
	[[ ${lines[5]} == *":15: asserção: resultado -eq esperado" ]]
	[[ ${lines[6]} == *":16: asserção: resultado -ne outro" ]]
}

@test "asserções dependem do diretório ou do nome do arquivo de teste" {
	for arquivo in test/caso.py tests/caso.py src/test/caso.py test_caso.py \
		caso_test.py caso.test.js verifica.bats; do
		printf '%s\n' "--- a/$arquivo" "+++ b/$arquivo" '@@ -1 +1 @@' \
			'-assert resultado' '+texto' >patch
		run "$SCRIPT" --so asserção patch
		[ "$status" -eq 1 ]
		[ "$output" = "$arquivo:1: asserção: assert resultado" ]
	done
	for arquivo in latest.md attestation scripts/testes-da-revisao teste.py texto.md; do
		printf '%s\n' "--- a/$arquivo" "+++ b/$arquivo" '@@ -1 +1 @@' \
			'-assert resultado' '+texto' >patch
		run "$SCRIPT" --so asserção patch
		[ "$status" -eq 0 ]
		[ -z "$output" ]
	done
}

@test "números novos se comparam com todas as retiradas, só no mesmo hunk" {
	cat >patch <<'EOF'
--- a/nota.md
+++ b/nota.md
@@ -10,2 +10,3 @@
-base 510, 187, 1.024 e 2026-10-31
-antigo
+outra base
+base 187, 510, 1.024 e 2026-10-31
+recontagem 612
@@ -20 +21 @@
-texto
+base 510
EOF
	run "$SCRIPT" --so número patch
	[ "$status" -eq 1 ]
	[ "$output" = $'nota.md:12: número: recontagem 612\nnota.md:21: número: base 510' ]
}

@test "sinal e separadores fazem parte do número comparado" {
	for par in '10|-10' '1.5|5.1' '1,5|5,1'; do
		velho=${par%|*}
		novo=${par#*|}
		printf '%s\n' '--- a/nota.md' '+++ b/nota.md' '@@ -1 +1 @@' \
			"-limite = $velho" "+limite = $novo" >patch
		run "$SCRIPT" --so número patch
		[ "$status" -eq 1 ]
		[ "$output" = "nota.md:1: número: limite = $novo" ]
	done
}

@test "número igual, com sinal ou separadores, continua sem marca" {
	for numero in -10 1.5 1,5 1.024; do
		printf '%s\n' '--- a/nota.md' '+++ b/nota.md' '@@ -1 +1 @@' \
			"-limite = $numero" "+base = $numero" >patch
		run "$SCRIPT" --so número patch
		[ "$status" -eq 0 ]
		[ -z "$output" ]
	done
}

@test "hunk truncado no meio da entrada sai com 2 e mensagem em stderr" {
	for cabecalho in 'diff --git a/outra.md b/outra.md' '@@ -10 +10 @@'; do
		printf '%s\n' '--- a/nota.md' '+++ b/nota.md' '@@ -1,2 +1,2 @@' \
			'-texto' '+outro' "$cabecalho" '-texto' '+outro' >patch
		run --separate-stderr "$SCRIPT" patch
		[ "$status" -eq 2 ]
		[ -z "$output" ]
		[[ $stderr == *"forca-no-patch:"*"hunk incompleto"* ]]
	done
}

@test "hunk truncado no fim da entrada sai com 2 e mensagem em stderr" {
	for fim in '' $'\n'; do
		printf '%s\n' '--- a/nota.md' '+++ b/nota.md' '@@ -1,2 +1,2 @@' \
			'-texto' >patch
		printf '%s%s' '+outro' "$fim" >>patch
		run --separate-stderr "$SCRIPT" patch
		[ "$status" -eq 2 ]
		[ -z "$output" ]
		[[ $stderr == *"forca-no-patch:"*"hunk incompleto"* ]]
	done
}

@test "dentro do hunk, linhas como cabeçalho são conteúdo pelos contadores" {
	# Um diff do difflib, sem contexto, que troca "-- a/exemplo" por
	# "++ b/exemplo": as duas linhas são do primeiro hunk, e o Nunca do
	# segundo hunk tem de sair.
	printf '%s\n' '--- a/doc.md' '+++ b/doc.md' '@@ -1 +1 @@' \
		'--- a/exemplo' '+++ b/exemplo' '@@ -12 +12 @@' \
		'-Nunca retire.' '+texto' >patch
	run --separate-stderr "$SCRIPT" --so força patch
	[ "$status" -eq 1 ]
	[ "$output" = 'doc.md:12: força: Nunca retire.' ]
}

@test "linha de contexto vazia, sem o espaço, conta como contexto" {
	printf '%s\n' '--- a/nota.md' '+++ b/nota.md' '@@ -1,3 +1,3 @@' \
		'-Nunca retire.' '+texto' '' ' fim' >patch
	run --separate-stderr "$SCRIPT" --so força patch
	[ "$status" -eq 1 ]
	[ "$output" = 'nota.md:1: força: Nunca retire.' ]
}

@test "cabeçalho @@ malformado e +++ sem hunk saem com 2; renomeação passa" {
	printf '%s\n' '--- a/nota.md' '+++ b/nota.md' '@@ -1 +1 @@' '-a' '+b' \
		'@@ -10 +10' '-Nunca retire.' '+pode agir.' >patch
	run --separate-stderr "$SCRIPT" patch
	[ "$status" -eq 2 ]
	[[ $stderr == *"cabeçalho de hunk malformado"* ]]
	printf '%s\n' 'diff --git a/x b/x' '--- a/x' '+++ b/x' >patch
	run --separate-stderr "$SCRIPT" patch
	[ "$status" -eq 2 ]
	[[ $stderr == *"sem nenhum hunk"* ]]
	for fim in '' 'diff --git a/y b/y' '@@ -1 +1 @@' '--- a/y'; do
		printf '%s\n' 'diff --git a/x b/x' '--- a/x' ${fim:+"$fim"} >patch
		run --separate-stderr "$SCRIPT" patch
		[ "$status" -eq 2 ]
		[[ $stderr == *"x: cabeçalho --- sem +++"* ]]
	done
	printf '%s\n' 'diff --git a/x b/y' 'similarity index 100%' \
		'rename from x' 'rename to y' >patch
	run --separate-stderr "$SCRIPT" patch
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "entrada padrão é lida em UTF-8, qualquer que seja a codificação do ambiente" {
	printf '%s\n' '--- a/nota.md' '+++ b/nota.md' '@@ -1 +1 @@' \
		'-Só agir assim.' '+texto' >patch
	# A saída sai na codificação do ambiente; o teste confere só o código e
	# o começo, sem acento.
	PYTHONIOENCODING=latin-1 run pela_entrada --so força
	[ "$status" -eq 1 ]
	[[ $output == 'nota.md:1: '* ]]
}

@test "não cancela retiradas com uma linha idêntica de outro hunk ou arquivo" {
	cat >patch <<'EOF'
diff --git a/nota.md b/nota.md
--- a/nota.md
+++ b/nota.md
@@ -1 +1 @@
-Nunca retire.
+texto
@@ -10 +10 @@
-texto
+Nunca retire.
diff --git a/outra.md b/outra.md
--- a/outra.md
+++ b/outra.md
@@ -1 +1 @@
-Nunca retire.
+texto
EOF
	run "$SCRIPT" patch
	[ "$status" -eq 1 ]
	[ "$output" = $'nota.md:1: força: Nunca retire.\noutra.md:1: força: Nunca retire.' ]
}

@test "reconhece todas as palavras de força e de permissão" {
	for palavra in Nunca nunca Sempre sempre jamais 'tem de' 'têm de' \
		'não pode' 'não podem' proíbe recusa portão obrigatório 'só ' 'Só ' \
		apenas 'deve ' 'devem ' Jamais 'Tem de' 'Não pode' Proíbe Recusa \
		Apenas 'Deve '; do
		printf '%s\n' '--- a/nota.md' '+++ b/nota.md' '@@ -1 +1 @@' \
			"-$palavra agir." '+texto' >patch
		run "$SCRIPT" patch
		[ "$status" -eq 1 ]
		[ "$output" = "nota.md:1: força: $palavra agir." ]
	done
	for palavra in 'pode ' 'podem ' basta opcional dispensa 'se não houver' \
		'à vontade' 'Sem fonte, escreva'; do
		printf '%s\n' '--- a/nota.md' '+++ b/nota.md' '@@ -1 +1 @@' \
			'-texto' "+$palavra algo." >patch
		run "$SCRIPT" patch
		[ "$status" -eq 1 ]
		[ "$output" = "nota.md:1: permissão: $palavra algo." ]
	done
}

@test "lê stdin sem argumento e com -, e --so repetido restringe os tipos" {
	cat >patch <<'EOF'
--- a/nota.md
+++ b/nota.md
@@ -1 +1 @@
-Nunca retire.
+pode contar 612
EOF
	run pela_entrada
	[ "$status" -eq 1 ]
	[ "${#lines[@]}" -eq 3 ]
	run pela_entrada -
	[ "$status" -eq 1 ]
	[ "${#lines[@]}" -eq 3 ]
	run pela_entrada --so permissão --so número -
	[ "$status" -eq 1 ]
	[ "$output" = $'nota.md:1: permissão: pode contar 612\nnota.md:1: número: pode contar 612' ]
	run "$SCRIPT" --so asserção patch
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "format-patch e bloco cercado preservam o caminho e os contadores" {
	cat >patch <<'EOF'
From assunto
Assunto: conserto

bloco de patch:
diff --git a/nota.md b/nota.md
--- a/nota.md
+++ b/nota.md
@@ -10,2 +20,2 @@
 contexto
-Nunca retire.
+pode agir.
\ No newline at end of file
EOF
	printf '%s\n' '-- ' fim >>patch
	run "$SCRIPT" patch
	[ "$status" -eq 1 ]
	[ "$output" = $'nota.md:11: força: Nunca retire.\nnota.md:21: permissão: pode agir.' ]
}

@test "entrada sem diff e arquivo ilegível saem com 2 e mensagem em stderr" {
	printf 'Nunca retire.\n' >patch
	run --separate-stderr "$SCRIPT" patch
	[ "$status" -eq 2 ]
	[ -z "$output" ]
	[[ $stderr == *"forca-no-patch:"*"não é um diff"* ]]
	run --separate-stderr "$SCRIPT" inexistente
	[ "$status" -eq 2 ]
	[ -z "$output" ]
	[[ $stderr == *"forca-no-patch:"* ]]
	run --separate-stderr "$SCRIPT" .
	[ "$status" -eq 2 ]
	[ -z "$output" ]
	[[ $stderr == *"forca-no-patch:"* ]]
}

@test "cabeçalhos preservam espaços, aspas e nomes citados pelo git" {
	cat >patch <<'EOF'
diff --git a/nota do autor's.md b/nota do autor's.md
--- a/nota do autor's.md
+++ b/nota do autor's.md
@@ -1 +1 @@
-Nunca retire.
+texto
diff --git "a/n\303\272mero.md" "b/n\303\272mero.md"
--- "a/n\303\272mero.md"
+++ "b/n\303\272mero.md"
@@ -1 +1 @@
-Nunca retire.
+texto
EOF
	run "$SCRIPT" patch
	[ "$status" -eq 1 ]
	esperado=$(cat <<'EOF'
nota do autor's.md:1: força: Nunca retire.
número.md:1: força: Nunca retire.
EOF
	)
	[ "$output" = "$esperado" ]
}

@test "caminho entre aspas com UTF-8 literal e escape mantém o nome; aspas a mais saem com 2" {
	# Com core.quotePath=false, o git escreve "Ã©" literal e o TAB como \t.
	printf '%s\n' '--- "a/Ã©\t.md"' '+++ "b/Ã©\t.md"' '@@ -1 +1 @@' \
		'-Nunca retire.' '+texto' >patch
	run "$SCRIPT" patch
	[ "$status" -eq 1 ]
	[ "$output" = $'Ã©\t.md:1: força: Nunca retire.' ]
	printf '%s\n' 'diff --git a/x b/x' '--- "a/x", "y"' '+++ b/x' '@@ -1 +1 @@' \
		'-a' '+b' >patch
	run --separate-stderr "$SCRIPT" patch
	[ "$status" -eq 2 ]
	[[ $stderr == *"caminho entre aspas malformado"* ]]
	[[ $stderr != *Traceback* ]]
}

@test "permissão no começo da frase, com maiúscula, também se marca" {
	printf '%s\n' '--- a/nota.md' '+++ b/nota.md' '@@ -1 +1 @@' \
		'-texto' '+Pode pular a revisão. Basta isso.' >patch
	run "$SCRIPT" --so permissão patch
	[ "$status" -eq 1 ]
	[ "$output" = 'nota.md:1: permissão: Pode pular a revisão. Basta isso.' ]
}

@test "cabeçalho entre aspas malformado sai com 2 e mensagem em stderr" {
	printf '%s\n' 'diff --git a/x b/x' '--- "a/x' >patch
	run --separate-stderr "$SCRIPT" patch
	[ "$status" -eq 2 ]
	[ -z "$output" ]
	[[ $stderr == *"forca-no-patch:"*"não foi possível conferir a entrada:"* ]]
	[[ $stderr != *Traceback* ]]
}

@test "cada reposição cancela só uma retirada idêntica no hunk" {
	for texto in 'assert ok' 'Nunca retire a regra.'; do
		printf '%s\n' '--- a/teste.bats' '+++ b/teste.bats' '@@ -1,2 +1 @@' \
			"-$texto" "-$texto" "+$texto" >patch
		run "$SCRIPT" patch
		[ "$status" -eq 1 ]
		if [ "$texto" = 'assert ok' ]; then
			[ "$output" = 'teste.bats:2: asserção: assert ok' ]
		else
			[ "$output" = 'teste.bats:2: força: Nunca retire a regra.' ]
		fi
	done
}

@test "só LF separa linhas do diff, também com terminadores CRLF" {
	for separador in $'\u2028' $'\u2029' $'\v' $'\f' $'\r' $'\u0085' \
		$'\x1c' $'\x1d' $'\x1e'; do
		for fim in $'\n' $'\r\n'; do
			printf '%s%s' '--- a/nota.md' "$fim" '+++ b/nota.md' "$fim" \
				'@@ -1 +1 @@' "$fim" "-texto${separador}Nunca retire a regra." "$fim" \
				'+outro' "$fim" >patch
			run "$SCRIPT" patch
			[ "$status" -eq 1 ]
			[ "$output" = "nota.md:1: força: texto${separador}Nunca retire a regra." ]
			run pela_entrada
			[ "$status" -eq 1 ]
			[ "$output" = "nota.md:1: força: texto${separador}Nunca retire a regra." ]
		done
	done
}

@test "escolha inválida e opção desconhecida mostram o erro de uso e --help" {
	run --separate-stderr "$SCRIPT" --so=-1
	[ "$status" -eq 2 ]
	[ -z "$output" ]
	[[ $stderr == *"invalid choice:"*"-1"*"--help"* ]]
	run --separate-stderr "$SCRIPT" --desconhecida
	[ "$status" -eq 2 ]
	[ -z "$output" ]
	[[ $stderr == *"unrecognized arguments: --desconhecida"*"--help"* ]]
}
