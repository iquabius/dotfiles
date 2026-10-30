---
name: adr
description: >-
  Registra decisões de projeto em docs/adr/NNNN-slug.md, em português,
  enxutos, com o título no nome do arquivo e o corpo em ordem fixa
  (problema, critérios, decisão, alternativas, custo), com data absoluta.
  Use quando uma decisão cara de reverter for tomada ou substituída, quando
  o usuário pedir "registre a decisão", "escreva um ADR", "por que
  escolhemos X", e ao gravar ADRs durante o grill-with-docs. Não use para
  decisão ainda em discussão (grilling), para convenção de código ou de
  pastas (AGENTS.md) nem para tarefas (o rastreador do repositório).
  Também em inglês: "ADR", "record this decision", "architecture decision
  record".
---

# ADR

Formato, pasta e critérios vêm do `ADR-FORMAT.md` da skill `domain-modeling`:
`docs/adr/NNNN-slug.md` e numeração sequencial. Esta skill fixa o que fica
em cima disso: o ADR tem o tamanho que a cadeia das decisões pede, e nada
mais, para quem o lê semanas depois, pessoa ou agente, sem a conversa que o
gerou. O `AGENTS.md` do repositório prevalece onde disser outra coisa.

## Quando registrar

Os três critérios do `domain-modeling`, todos: cara de reverter; surpreende
quem lê sem contexto; houve alternativa real. Faltando um, não é ADR:
convenção vai para o `AGENTS.md`, tarefa para o rastreador, achado para a
análise do texto.

## Forma

```markdown
# NNNN. <O nome do arquivo em palavras>

<AAAA-MM-DD.> <Quem sente o problema e o que perde com ele; o problema, em uma a três frases, sem a decisão.>

Critérios:

- <o que a decisão precisa garantir, até cinco itens>

<A decisão, aberta pela frase do título, e o porquê.>

Em vez de: <alternativa>, <seu argumento mais forte>; <o critério que ela não cumpre>.
Em vez de: <a outra alternativa, do mesmo jeito>.
Custo: <o que fica mais difícil>.

Fontes: <pesquisa, commit, ADR anterior>.
```

- Título é o nome do arquivo em palavras, com acentos, maiúsculas,
  pontuação e o artigo do começo que o nome cortou, sem crase nem itálico:
  um nome só no `ls`, no chat e onde o título for citado. O nome, sem o
  número e sem o `.md`, tem até 70 caracteres e começa pela palavra que
  distingue o ADR dos vizinhos; listas e o que muda a cada redesenho vão
  para o corpo. Por exemplo,
  `0023-rascunho-e-a-arvore-de-trabalho-e-o-commit-espera-a-revisao.md`
  tem o título "O rascunho é a árvore de trabalho e o commit espera a
  revisão".
- Título é a decisão, não a pergunta: "Android entra com Views e Compose",
  não "Qual toolkit no Android?".
- Cada parte abre pelo que o leitor já reconhece; o nome técnico vem da
  segunda frase em diante.
- A primeira frase do problema diz quem o sente (o leitor do documento,
  quem mantém o código, o usuário) e o que perde com ele, como a abertura
  de um bom cartão de tarefa; o impacto não ganha seção própria.
- Data absoluta na primeira frase. Nada de "hoje", "atual", "recente",
  "novo": afirmação sobre ferramenta leva versão e data ("React 19.3.0, npm,
  2026-09").
- "Em vez de" e "Custo" são obrigatórios e nunca vazios. Só as
  alternativas que a cadeia pede: a decisão anterior que esta substitui e a
  que um leitor proporia, cada uma no seu `Em vez de:`, com o argumento a
  favor e o critério que ela não cumpre. Alternativa sem o argumento a
  favor é espantalho.
- Uma linha `Fontes:` quando a decisão se apoia em número ou documento
  (pesquisa, commit, ADR anterior).
- Português; termos técnicos em inglês quando não há tradução corrente; os
  termos do `GLOSSARY.md` do projeto, quando existe.
- Sem muletas ("vale ressaltar", "é importante"), sem elogio à decisão, sem
  ressalva empilhada. Ressalva que delimita fica com a força original.

## Ciclo de vida

- Decisão que muda reescreve o ADR no lugar: a data nova na primeira
  frase e a decisão anterior num "Em vez de", com o argumento a favor e o
  critério que ela não cumpre. O "Em vez de" que a cadeia deixou de
  pedir sai. Errata de fato (data, nome, número) se corrige no texto. O
  git guarda as versões.
- O ADR absorvido por outro sai, e o que deixa de passar nos três
  critérios sai para a regra do `AGENTS.md`, o verbete do glossário ou o
  docstring que já diz quase tudo dele. O que sai ganha, no mesmo commit,
  uma linha no histórico dos ADRs que saíram (por exemplo,
  `docs/processo/historico-dos-adrs.md`), com o commit pelo assunto, a
  data e o destino, e as citações do número passam ao destino, nos ADRs
  também. O texto dele se lê no pai do commit que o tirou: `git show
  <commit>^:docs/adr/<arquivo>`.
- O título que muda troca o nome do arquivo, com o caminho em todas as
  referências, num commit só de movimento, antes do que muda o texto. A
  troca não ganha linha no histórico: o `git log --follow` a acha.
- Número: o maior em `docs/adr/` mais um, com quatro dígitos; a numeração
  tem lacunas, e o número de um ADR que saiu não volta. Slug em
  minúsculas, sem acento, com hífens. Sem índice: `ls docs/adr/` é o índice.

## Antes de gravar

- [ ] Os três critérios valem.
- [ ] Título igual ao nome do arquivo, até 70 caracteres; data na
  primeira frase.
- [ ] Ordem: problema, "Critérios:", decisão, "Em vez de:", "Custo:" e,
  quando houver, "Fontes:".
- [ ] A primeira frase do problema diz quem o sente e o que perde.
- [ ] Cada alternativa com o argumento a favor e o critério que ela não
  cumpre; custo preenchido.
- [ ] Nenhum "hoje/atual/recente/novo" sem data ou versão.
- [ ] Lido frio: faz sentido sem a conversa que o gerou.

## Fontes

Adaptado de `mattpocock/skills` (domain-modeling, formato e os três
critérios; MIT), `tech-leads-club/agent-skills` (create-adr, antipadrões:
título como pergunta, contexto vago, consequência sem custo; CC-BY-4.0) e
`riekelt/technical-writer` (recording-decisions: datas absolutas, custo
obrigatório; MIT). A ordem do corpo e a abertura pelo que o leitor
reconhece vêm da skill `mensagem-de-commit` (o problema antes da solução,
a alternativa recusada) e do cartão de tarefa (problema, o que conta como
sucesso, solução), numa decisão de 2026-10-25; dela vêm também o título no
nome do arquivo e o histórico do que sai. A reescrita no lugar e a
numeração com lacunas, no lugar do ADR imutável, substituído por outro, da
`recording-decisions`, vêm de um corte de ADRs em 2026-10-05.
