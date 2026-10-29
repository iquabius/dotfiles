#!/usr/bin/env bats
# Testes do bin/.local/bin/skills-sync.
#
# Cada teste monta um repo de brinquedo e um $HOME de brinquedo em
# $BATS_TEST_TMPDIR; o script é apontado para eles por SKILLS_SYNC_REPO e
# SKILLS_SYNC_TARGET e nunca encosta no $HOME de verdade. Cada caso de borda
# que aparecer no uso real vira um teste aqui.

# SKILLS_SYNC_SCRIPT troca o script testado (útil para conferir, com uma
# cópia sabotada, que o teste de fato pega a falha).
SCRIPT="${SKILLS_SYNC_SCRIPT:-$BATS_TEST_DIRNAME/../bin/.local/bin/skills-sync}"

setup() {
	REPO=$BATS_TEST_TMPDIR/repo
	T=$BATS_TEST_TMPDIR/home
	mkdir -p "$REPO/skills" "$REPO/profiles" "$T"
	export SKILLS_SYNC_REPO=$REPO SKILLS_SYNC_TARGET=$T
}

# Pacote de skill no mesmo layout do repo real, com os dois links versionados.
mkskill() {
	for s in "$@"; do
		d=$REPO/skills/$s
		mkdir -p "$d/.agents/skills/$s" "$d/.claude/skills" "$d/.cursor/skills"
		printf -- '---\nname: %s\n---\n' "$s" >"$d/.agents/skills/$s/SKILL.md"
		ln -s "../../.agents/skills/$s" "$d/.claude/skills/$s"
		ln -s "../../.agents/skills/$s" "$d/.cursor/skills/$s"
	done
}

# profile <nome> <linha>... — grava profiles/<nome>.pkgs
profile() {
	name=$1
	shift
	printf '%s\n' "$@" >"$REPO/profiles/$name.pkgs"
}

# use <perfil>... — grava .profile.local
use() {
	printf '%s\n' "$@" >"$REPO/.profile.local"
}

sync() {
	run "$SCRIPT" "$@"
}

linked() {
	for a in .agents .claude .cursor; do
		[ -r "$T/$a/skills/$1/SKILL.md" ] || {
			echo "não chega: $a/skills/$1" >&2
			return 1
		}
	done
}

unlinked() {
	for a in .agents .claude .cursor; do
		if [ -e "$T/$a/skills/$1" ] || [ -L "$T/$a/skills/$1" ]; then
			echo "ainda existe: $a/skills/$1" >&2
			return 1
		fi
	done
}

dirs_real() {
	for d in .agents .agents/skills .claude .claude/skills .cursor .cursor/skills; do
		[ -d "$T/$d" ] && [ ! -L "$T/$d" ] || {
			echo "não é diretório real: $d" >&2
			return 1
		}
	done
}

# Tudo sob $T que existe, para comparar antes/depois.
snapshot() {
	(cd "$T" && find . | sort)
}

@test "máquina nova: cria os diretórios, as âncoras e liga as skills do perfil" {
	mkskill a b
	profile comum a b
	use comum
	sync
	[ "$status" -eq 0 ]
	linked a
	linked b
	dirs_real
	[ -f "$T/.agents/skills/.keep" ]
	[ -f "$T/.cursor/skills/.keep" ]
	[[ "$output" == *"liga:     a"* ]]
}

@test "rodar de novo não muda nada e diz que não há o que fazer" {
	mkskill a
	profile comum a
	use comum
	sync
	before=$(snapshot)
	sync
	[ "$status" -eq 0 ]
	[ "$(snapshot)" = "$before" ]
	[[ "$output" == "nada a fazer: 1 skill(s) do perfil já ligada(s)" ]]
}

@test "junta vários perfis e ignora duplicata" {
	mkskill a b c
	profile comum a b
	profile pessoal b c
	use comum pessoal
	sync
	[ "$status" -eq 0 ]
	linked a
	linked b
	linked c
}

@test "ignora comentário, linha vazia, espaço nas pontas e CRLF" {
	mkskill a b
	printf '# cabeçalho\n\n  a  \r\n\tb # comentário no fim\n\n' >"$REPO/profiles/comum.pkgs"
	printf 'comum\r\n\n# nada\n' >"$REPO/.profile.local"
	sync
	[ "$status" -eq 0 ]
	linked a
	linked b
	# linha vazia chegando ao stow criaria $T/<skill> na raiz do alvo
	[ ! -e "$T/a" ] && [ ! -e "$T/b" ]
}

@test ".pkgs.local liga skill só nesta máquina e o sync seguinte a mantém" {
	mkskill a extra
	profile comum a
	use comum
	printf '# só aqui\nextra\n' >"$REPO/.pkgs.local"
	sync
	sync
	[ "$status" -eq 0 ]
	linked a
	linked extra
	# tirar do .pkgs.local desliga, como tirar do perfil
	rm "$REPO/.pkgs.local"
	sync
	unlinked extra
}

@test "skill que saiu do perfil é desligada; as outras ficam" {
	mkskill a b
	profile comum a b
	use comum
	sync
	profile comum a
	sync
	[ "$status" -eq 0 ]
	linked a
	unlinked b
	[[ "$output" == *"desliga:  b"* ]]
}

@test "skill apagada do repo por um pull: os links pendurados saem" {
	mkskill a b
	profile comum a b
	use comum
	sync
	# o que um pull faz quando outra máquina remove a skill
	rm -rf "$REPO/skills/b"
	profile comum a
	sync
	[ "$status" -eq 0 ]
	linked a
	unlinked b
}

@test "desligar até sobrar uma skill não dobra os diretórios" {
	mkskill a b
	profile comum a b
	use comum
	sync
	profile comum a
	sync
	[ "$status" -eq 0 ]
	dirs_real
	[ -L "$T/.agents/skills/a" ]
}

@test "perfil vazio desliga tudo e mantém os diretórios reais" {
	mkskill a
	profile comum a
	profile trabalho '# vazio de propósito'
	use comum
	sync
	use trabalho
	sync
	[ "$status" -eq 0 ]
	unlinked a
	dirs_real
}

@test "não toca skill não versionada nem link de outra origem" {
	mkskill a
	profile comum a
	use comum
	mkdir -p "$T/.agents/skills/solta" "$T/.claude/skills" "$T/elsewhere/x"
	echo x >"$T/.agents/skills/solta/SKILL.md"
	ln -s ../../.agents/skills/solta "$T/.claude/skills/solta"
	ln -s ../../elsewhere/x "$T/.claude/skills/de-fora"
	ln -s ../../nao/existe "$T/.claude/skills/pendurado-alheio"
	sync
	[ "$status" -eq 0 ]
	[ -f "$T/.agents/skills/solta/SKILL.md" ]
	[ -L "$T/.claude/skills/solta" ]
	[ -L "$T/.claude/skills/de-fora" ]
	[ -L "$T/.claude/skills/pendurado-alheio" ]
}

@test "link com o formato certo mas de outro repo não é removido" {
	mkskill a
	profile comum a
	use comum
	# outro stow dir com uma skill z, ligada no mesmo formato relativo
	mkdir -p "$BATS_TEST_TMPDIR/outro/skills/z/.claude/skills/z" "$T/.claude/skills"
	ln -s ../../../outro/skills/z/.claude/skills/z "$T/.claude/skills/z"
	sync
	[ "$status" -eq 0 ]
	[ -L "$T/.claude/skills/z" ]
	[[ "$output" != *"desliga"* ]]
}

@test "liga só o link que falta quando a skill está pela metade" {
	mkskill a
	profile comum a
	use comum
	sync
	rm "$T/.cursor/skills/a"
	sync
	[ "$status" -eq 0 ]
	linked a
	[[ "$output" == *"liga:     a"* ]]
}

@test "dry-run mostra o plano e não muda nada" {
	mkskill a b
	profile comum a b
	use comum
	sync
	profile comum a
	mkskill c
	profile comum a c
	before=$(snapshot)
	sync --dry-run
	[ "$status" -eq 0 ]
	[ "$(snapshot)" = "$before" ]
	[[ "$output" == *"(dry-run) liga:     c"* ]]
	[[ "$output" == *"(dry-run) desliga:  b"* ]]
}

@test "dry-run numa máquina nova não cria diretório nenhum" {
	mkskill a
	profile comum a
	use comum
	sync -n
	[ "$status" -eq 0 ]
	[ -z "$(ls -A "$T")" ]
}

@test "sem .profile.local: erro claro e nada muda" {
	mkskill a
	profile comum a
	sync
	[ "$status" -eq 1 ]
	[[ "$output" == *"falta"*".profile.local"* ]]
	[ -z "$(ls -A "$T")" ]
}

@test "perfil desconhecido: erro antes de mexer em qualquer coisa" {
	mkskill a
	profile comum a
	use comum inexistente
	sync
	[ "$status" -eq 1 ]
	[[ "$output" == *"perfil desconhecido: inexistente"* ]]
	[ -z "$(ls -A "$T")" ]
}

@test "skill do perfil que não existe no repo: erro antes de mexer" {
	mkskill a
	profile comum a fantasma
	use comum
	sync
	[ "$status" -eq 1 ]
	[[ "$output" == *"não existe no repo: fantasma"* ]]
	[ -z "$(ls -A "$T")" ]
}

@test "nome de skill com caractere estranho é recusado" {
	profile comum '../fuga'
	use comum
	sync
	[ "$status" -eq 1 ]
	[[ "$output" == *"nome de skill inválido"* ]]
}

@test "diretório-alvo dobrado em symlink: recusa e não mexe" {
	mkskill a
	profile comum a
	use comum
	mkdir -p "$T/.agents" "$T/fora"
	ln -s ../fora "$T/.agents/skills"
	sync
	[ "$status" -eq 1 ]
	[[ "$output" == *"é symlink"* ]]
	[ -z "$(ls -A "$T/fora")" ]
}

@test "pasta real com o nome de uma skill do perfil: o stow recusa e o script falha" {
	mkskill a
	profile comum a
	use comum
	mkdir -p "$T/.agents/skills/a"
	echo antigo >"$T/.agents/skills/a/SKILL.md"
	sync
	[ "$status" -ne 0 ]
	[ "$(cat "$T/.agents/skills/a/SKILL.md")" = antigo ]
}

@test "opção desconhecida: uso e código 2" {
	sync --xyz
	[ "$status" -eq 2 ]
	[[ "$output" == *"Uso:"* ]]
}
