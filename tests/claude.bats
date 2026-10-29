#!/usr/bin/env bats
# Testes do pacote claude, que liga o ~/.claude/settings.json numa máquina
# sem a camada privada; nas que a têm, quem liga o arquivo é o pacote dela.
#
# O Claude Code grava esse arquivo (tema, plugins), e um programa que o
# reescreve pode trocar o symlink por um arquivo comum; aí o hook some do
# pacote sem erro nenhum. O último teste confere a máquina em que roda: é
# pulado sem o arquivo, com a camada privada ou com o link de outro pacote,
# e reprova com o arquivo comum.

# CLAUDE_SETTINGS troca o arquivo testado (útil para conferir, com uma cópia
# sabotada, que o teste de fato pega a falha).
PACOTE="${CLAUDE_SETTINGS:-$BATS_TEST_DIRNAME/../claude/.claude/settings.json}"

@test "o settings.json do pacote é JSON válido" {
	python3 -m json.tool "$PACOTE" >/dev/null
}

@test "o hook PreToolUse do Bash aponta para o claude-revisao-guarda do pacote bin" {
	run python3 -c '
import json, sys
d = json.load(open(sys.argv[1]))
cmds = [h["command"] for m in d["hooks"]["PreToolUse"] if m.get("matcher") == "Bash"
        for h in m["hooks"]]
print("\n".join(cmds))' "$PACOTE"
	[ "$status" -eq 0 ]
	[[ $output == *'$HOME/.local/bin/claude-revisao-guarda'* ]]
	[ -x "$BATS_TEST_DIRNAME/../bin/.local/bin/claude-revisao-guarda" ]
}

@test "nesta máquina, ~/.claude/settings.json ainda é o symlink do pacote" {
	alvo="$HOME/.claude/settings.json"
	[ -L "$alvo" ] || [ -e "$alvo" ] || skip "sem ~/.claude/settings.json"
	# Com a camada privada, o arquivo é do pacote dela, que o confere.
	[ ! -d "$HOME/.dotfiles-private" ] || skip "a camada privada liga o arquivo"
	case $(readlink "$alvo" 2>/dev/null) in
	*/.dotfiles/claude/.claude/settings.json) ;;
	*) [ -L "$alvo" ] && skip "ligado por outro pacote" ;;
	esac
	[ -L "$alvo" ] || {
		echo "$alvo virou arquivo comum: compare com o pacote, junte as mudanças em claude/ e rode stow -R claude" >&2
		return 1
	}
	[ "$(readlink -f "$alvo")" = "$(readlink -f "$PACOTE")" ]
}
