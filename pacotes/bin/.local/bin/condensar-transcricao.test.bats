#!/usr/bin/env bats
# Testes do condensar-transcricao, ao lado deste arquivo. A suíte cria
# transcrições JSONL e confere os blocos, os cortes e os códigos de saída.
# CONDENSAR_TRANSCRICAO_SCRIPT aponta para a cópia sabotada, sem mudar a suíte.

bats_require_minimum_version 1.5.0

SCRIPT="${CONDENSAR_TRANSCRICAO_SCRIPT:-$BATS_TEST_DIRNAME/condensar-transcricao}"

setup() {
	cd "$BATS_TEST_TMPDIR"
}

@test "linha original, timestamp, papel, string, lista e blocos vazios" {
	cat >sessao.jsonl <<'EOF'
{"timestamp":"agora","message":{"role":"assistant","content":"texto do agente"}}
isto não é JSON
{"timestamp":"depois","message":{"role":"user","content":[{"type":"text","text":"texto do autor"},{"type":"text","text":""},{"type":"tool_result","content":""}]}}
{"timestamp":"ignorado"}
{"message":{"role":"assistant","content":[]}}
null
EOF
	run "$SCRIPT" sessao.jsonl
	[ "$status" -eq 0 ]
	esperado=$(printf '# %s/sessao.jsonl\n\n' "$PWD"
		cat <<'EOF'
### L1 agora assistant texto
texto do agente

### L3 depois user texto
texto do autor
EOF
	)
	[ "$output" = "$esperado" ]
}

@test "texto do agente e do autor sai inteiro, mesmo com cortes pequenos" {
	python3 - <<'PY' >sessao.jsonl
import json
for papel in ("assistant", "user"):
    print(json.dumps({"message": {"role": papel, "content": [
        {"type": "text", "text": "  " + "á" * 1024 + "\nfim  "}
    ]}}, ensure_ascii=False))
PY
	run "$SCRIPT" --corte-ferramenta 1 --corte-resultado 1 sessao.jsonl
	[ "$status" -eq 0 ]
	esperado=$(python3 - <<'PY'
import os
print(f"# {os.path.abspath('sessao.jsonl')}\n")
for numero, papel in enumerate(("assistant", "user"), 1):
    print(f"### L{numero} ? {papel} texto\n  " + "á" * 1024 + "\nfim  \n")
PY
	)
	[ "$output" = "$esperado" ]
}

@test "cortes padrão contam caracteres omitidos na ferramenta e no resultado" {
	python3 - <<'PY' >sessao.jsonl
import json
print(json.dumps({"message": {"role": "assistant", "content": [
    {"type": "tool_use", "name": "exec", "input": {"texto": "á" * 1024}},
    {"type": "tool_result", "content": "é" * 1024}
]}}, ensure_ascii=False))
PY
	run "$SCRIPT" sessao.jsonl
	[ "$status" -eq 0 ]
	esperado=$(python3 - <<'PY'
import os
print(f"# {os.path.abspath('sessao.jsonl')}\n")
print('### L1 ? assistant ferramenta exec\n{"texto": "' + "á" * 689 + " […+337]\n")
print("### L1 ? assistant resultado\n" + "é" * 900 + " […+124]\n")
PY
	)
	[ "$output" = "$esperado" ]
}

@test "as duas opções cortam o JSON e o resultado em lista, com sufixo exato" {
	cat >sessao.jsonl <<'EOF'
{"timestamp":"agora","message":{"role":"assistant","content":[{"type":"tool_use","name":"exec","input":{"x":"áé"}},{"type":"tool_result","content":[{"type":"text","text":"áé"},{"type":"text","text":"fim"}]}]}}
EOF
	run "$SCRIPT" --corte-ferramenta 1 --corte-resultado 3 sessao.jsonl
	[ "$status" -eq 0 ]
	esperado=$(printf '# %s/sessao.jsonl\n\n' "$PWD"
		cat <<'EOF'
### L1 agora assistant ferramenta exec
{ […+10]

### L1 agora assistant resultado
áé  […+3]
EOF
	)
	[ "$output" = "$esperado" ]
}

@test "limite exato não ganha sufixo e corte zero conta tudo" {
	cat >sessao.jsonl <<'EOF'
{"message":{"role":"assistant","content":[{"type":"tool_use","name":"exec","input":{}},{"type":"tool_result","content":"fim"}]}}
EOF
	run "$SCRIPT" --corte-ferramenta 2 --corte-resultado 3 sessao.jsonl
	[ "$status" -eq 0 ]
	esperado=$(printf '# %s/sessao.jsonl\n\n' "$PWD"
		printf '### L1 ? assistant ferramenta exec\n{}\n\n### L1 ? assistant resultado\nfim\n')
	[ "$output" = "$esperado" ]
	run "$SCRIPT" --corte-ferramenta 0 --corte-resultado 0 sessao.jsonl
	[ "$status" -eq 0 ]
	esperado=$(printf '# %s/sessao.jsonl\n\n' "$PWD"
		printf '### L1 ? assistant ferramenta exec\n […+2]\n\n### L1 ? assistant resultado\n […+3]\n')
	[ "$output" = "$esperado" ]
}

@test "arquivo inexistente ou ilegível sai com 2 e mensagem em stderr" {
	run --separate-stderr "$SCRIPT" inexistente.jsonl
	[ "$status" -eq 2 ]
	[ -z "$output" ]
	[[ $stderr == *"condensar-transcricao:"*"não foi possível ler"* ]]
	run --separate-stderr "$SCRIPT" .
	[ "$status" -eq 2 ]
	[ -z "$output" ]
	[[ $stderr == *"condensar-transcricao:"*"não foi possível ler"* ]]
}

@test "limites negativos e opção desconhecida mostram o erro de uso e --help" {
	for opcao in --corte-ferramenta --corte-resultado; do
		run --separate-stderr "$SCRIPT" "$opcao" -1 sessao.jsonl
		[ "$status" -eq 2 ]
		[ -z "$output" ]
		[[ $stderr == *"os limites não podem ser negativos"*"--help"* ]]
	done
	run --separate-stderr "$SCRIPT" --desconhecida sessao.jsonl
	[ "$status" -eq 2 ]
	[ -z "$output" ]
	[[ $stderr == *"unrecognized arguments: --desconhecida"*"--help"* ]]
}

@test "sem timestamp, role ou name, cada campo ausente sai como ?" {
	cat >sessao.jsonl <<'EOF'
{"message":{"content":[{"type":"text","text":"texto"},{"type":"tool_use","input":{}}]}}
EOF
	run "$SCRIPT" sessao.jsonl
	[ "$status" -eq 0 ]
	esperado=$(printf '# %s/sessao.jsonl\n\n' "$PWD"
		cat <<'EOF'
### L1 ? ? texto
texto

### L1 ? ? ferramenta ?
{}
EOF
	)
	[ "$output" = "$esperado" ]
}

@test "role e name nulos saem como ?, como os ausentes" {
	cat >sessao.jsonl <<'EOF'
{"timestamp":null,"message":{"role":null,"content":[{"type":"tool_use","name":null,"input":{}}]}}
EOF
	run "$SCRIPT" sessao.jsonl
	[ "$status" -eq 0 ]
	[[ ${lines[1]} == '### L1 ? ? ferramenta ?' ]]
}

@test "comando enfileirado sai inteiro, com a origem; outros anexos se pulam" {
	cat >sessao.jsonl <<'EOF'
{"type":"attachment","timestamp":"t1","attachment":{"type":"queued_command","commandMode":"task-notification","origin":{"kind":"task-notification"},"prompt":"<task-notification>lote pronto</task-notification>"}}
{"type":"attachment","timestamp":"t2","attachment":{"type":"queued_command","commandMode":"prompt","origin":{"kind":"peer","from":"a1"},"prompt":"<agent-message from=\"a1\">relatório do eixo</agent-message>"}}
{"type":"attachment","attachment":{"type":"queued_command","commandMode":"prompt","prompt":[{"type":"text","text":"resposta do autor"},{"type":"image"}]}}
{"type":"attachment","timestamp":"t4","attachment":{"type":"prompt_snapshot","prompt":"não sai"}}
EOF
	run "$SCRIPT" --corte-resultado 3 sessao.jsonl
	[ "$status" -eq 0 ]
	esperado=$(printf '# %s/sessao.jsonl\n\n' "$PWD"
		cat <<'EOF'
### L1 t1 user fila task-notification
<task-notification>lote pronto</task-notification>

### L2 t2 user fila peer
<agent-message from="a1">relatório do eixo</agent-message>

### L3 ? user fila prompt
resposta do autor
EOF
	)
	[ "$output" = "$esperado" ]
}

@test "surrogate solto no texto e na ferramenta sai escrito, sem traceback" {
	cat >sessao.jsonl <<'EOF'
{"message":{"role":"assistant","content":[{"type":"text","text":"a\ud800b"},{"type":"tool_use","name":"Bash","input":{"command":"x\ud800y"}}]}}
EOF
	run --separate-stderr "$SCRIPT" sessao.jsonl
	[ "$status" -eq 0 ]
	[ -z "$stderr" ]
	[[ $output == *'a\ud800b'* ]]
	[[ $output == *'x\ud800y'* ]]
}

@test "cano fechado por head -1 termina em silêncio, sem erro de leitura" {
	python3 - <<'PY' >sessao.jsonl
import json
print(json.dumps({"message": {"role": "assistant", "content": "texto\n" * (1024 * 1024)}}))
PY
	com_cano_fechado() {
		set -o pipefail
		"$SCRIPT" sessao.jsonl | head -1
	}
	run --separate-stderr com_cano_fechado
	[ "$status" -eq 0 ]
	[ "$output" = "# $PWD/sessao.jsonl" ]
	[ -z "$stderr" ]
}
