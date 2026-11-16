#!/usr/bin/env bats
# Testes do .stowrc da raiz, que deixa o stow rodado ali achar os pacotes
# em pacotes/ e ligá-los no $HOME sem opção na linha de comando.
#
# Cada teste copia o .stowrc para uma raiz de brinquedo em $BATS_TEST_TMPDIR,
# com um pacote p em pacotes/, e roda ali o stow com um $HOME descartável,
# que não tem .stowrc próprio: o stow -n, que só diz o que faria, ou o
# stow de verdade, que liga o pacote nesse $HOME.

# STOWRC troca o arquivo testado (útil para conferir, com uma cópia
# sabotada, que o teste de fato pega a falha).
STOWRC="${STOWRC:-$BATS_TEST_DIRNAME/../.stowrc}"

setup() {
	export HOME=$BATS_TEST_TMPDIR/casa
	RAIZ=$BATS_TEST_TMPDIR/raiz
	mkdir -p "$HOME" "$RAIZ/pacotes/p"
	cp "$STOWRC" "$RAIZ/.stowrc"
	echo x >"$RAIZ/pacotes/p/.arq"
	cd "$RAIZ"
}

@test "o stow rodado na raiz acha o pacote em pacotes/" {
	run stow -n -v2 p
	[ "$status" -eq 0 ]
	[[ $output == *"stow dir is $RAIZ/pacotes"$'\n'* ]]
	[[ $output == *"LINK: .arq => ../raiz/pacotes/p/.arq"* ]]
}

@test "o stow rodado na raiz liga no \$HOME expandido" {
	run stow -n -v2 p
	[ "$status" -eq 0 ]
	[[ $output == *"relative to target $HOME is ../raiz/pacotes"* ]]
}

# O log do -v2 não é contrato do Stow: este confere o link que ele cria.
@test "o stow rodado na raiz cria no \$HOME o link para o pacote" {
	run stow p
	[ "$status" -eq 0 ]
	[ "$(readlink "$HOME/.arq")" = ../raiz/pacotes/p/.arq ]
}
