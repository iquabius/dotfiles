#!/usr/bin/env bats
# Testes da lista de caminhos de código (.config/revisao) deste repositório:
# os arquivos que ligam os portões do ciclo têm de estar nela, ou um ramo
# que os desliga chega ao main sem revisão.
#
# REVISAO_LISTA troca a lista testada (útil para conferir, com uma cópia
# sabotada, que o teste de fato pega a falha).
RAIZ="$BATS_TEST_DIRNAME/.."
LISTA="${REVISAO_LISTA:-$RAIZ/.config/revisao}"

# coberto <arquivo> — passa se algum pathspec da lista casa com o arquivo.
# Lê a lista como o config() do git-revisao: cada linha aparada, sem as
# vazias, as de comentário e a "teste:". Lista ausente ou sem pathspec
# reprova: o git ls-files sem pathspec listaria o repositório inteiro.
coberto() {
	local specs=() linha
	[ -f "$LISTA" ]
	while IFS= read -r linha || [ -n "$linha" ]; do
		linha="${linha#"${linha%%[![:space:]]*}"}"
		linha="${linha%"${linha##*[![:space:]]}"}"
		case $linha in '' | '#'* | teste:*) continue ;; esac
		specs+=("$linha")
	done <"$LISTA"
	[ "${#specs[@]}" -gt 0 ]
	git -C "$RAIZ" ls-files -- "${specs[@]}" | grep -Fxq "$1"
}

@test "o git/.gitconfig, que liga os hooks do ciclo, é caminho revisado" {
	coberto git/.gitconfig
}

@test "o settings.json do pacote claude, que registra o guarda, é caminho revisado" {
	coberto claude/.claude/settings.json
}
