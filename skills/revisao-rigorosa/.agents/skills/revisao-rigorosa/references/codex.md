# O eixo Codex

Um segundo provedor de modelo, para que a revisão não dependa dos pontos
cegos de um modelo só. O Codex CLI da OpenAI roda um eixo cego sobre a
mudança inteira: ele nunca vê o que os outros eixos acharam, e os achados
dele passam pela mesma conferência que os deles antes de chegar ao
relatório.

## Confira que ele roda

```bash
command -v codex && codex login status && codex --version
```

Se qualquer um dos três falhar, o eixo não roda. Nunca rode `codex
login`, digite uma chave nem instale nada: o login é do autor. Configure o
Codex só por flags (`-m`, `-c key=value`), nunca por variáveis de
ambiente. Dentro de um contêiner distrobox, o wrapper `codex` passa a
chamada ao host por `distrobox-host-exec`, que mantém o diretório de
trabalho, o stdin e o código de saída, mas descarta o ambiente.

## A chamada

Escreva o brief abaixo num arquivo fora da árvore revisada (o scratchpad
da sessão ou um diretório temporário; dentro de um contêiner, um caminho
que o host também veja) e passe-o pelo stdin, para que o comando continue
curto por mais longo que seja o brief:

```bash
codex exec -m gpt-6.1-sol -c model_reasoning_effort=high \
  --sandbox read-only --ephemeral --color never \
  -C "$(git rev-parse --show-toplevel)" \
  -o <dir>/codex-review.md - < <dir>/codex-brief.md \
  > <dir>/codex-run.log 2>&1
```

- `exec`, não `codex review`: `codex exec review --commit <sha>
  "<prompt>"` recusa o prompt ("the argument '--commit <SHA>' cannot
  be used with '[PROMPT]'"), então não leva este brief, a especificação
  nem a língua da resposta; nem `codex review` nem `codex exec review` têm
  a flag `--sandbox`.
- `--sandbox read-only` deixa o Codex ler a árvore e rodar `git log`,
  `git show` e `git diff` sozinho, e recusa toda escrita. O Codex lê o
  diff do repositório; não o cole no brief.
- `--ephemeral` não guarda sessão; `-o` guarda só a mensagem final; `-`
  lê o prompt do stdin. O log leva a transcrição inteira (o brief, cada
  comando e a saída dele: 1.602 linhas para um commit de 488 linhas
  acrescentadas), então vai para um arquivo; leia só o cabeçalho dele
  (`head -11`: modelo, sandbox, esforço) e as linhas de que precisar.
- Modelo: a mesma regra de nível dos outros eixos, o modelo mais forte
  abaixo do carro-chefe. Em 2026-10-26, pelas descrições em `codex debug
  models`, era o `gpt-6.1-sol` ("workhorse"), abaixo do `gpt-6-astra`
  ("frontier"); a ordem da lista não os classifica. Quando ele sumir de
  `codex debug models`, escolha o mesmo nível pela descrição e diga-o no
  relatório. Antes, descarte um CLI desatualizado, cuja lista não traz os
  modelos mais novos e cujas chamadas a eles falham com "not supported
  when using Codex with a ChatGPT account": em 2026-10-28, o codex-cli
  0.157.1 fez as duas coisas com o `gpt-6.1-sol`, e o 0.165.0 o listou e
  respondeu. O `codex --version` contra o `latest_version` de
  `~/.codex/version.json` mostra a diferença, onde o CLI escreveu esse
  arquivo (um build 0.164.0-alpha não escreveu); atualizar o CLI é decisão
  do autor.
  `model_reasoning_effort=high`: o padrão do modelo é `low`, raso demais
  para uma revisão. Confira a linha `reasoning effort: high` do cabeçalho.
- O Codex acha sozinho as skills instaladas em `~/.agents/skills`: em
  2026-10-26, com um brief sem a linha que o proíbe, ele abriu o
  `SKILL.md` desta skill e o seguiu em vez do brief. Como esse arquivo
  traz este eixo, segui-lo é rodar o Codex de novo. A única chave de
  `codex features list` que nomeia o interruptor,
  `skip_host_skill_discovery`, está "under development", então o brief o
  proíbe. Procure no log um `cat` de um `SKILL.md`.
- Fora de um repositório git (um plano sem código), acrescente
  `--skip-git-repo-check` e tire o `-C`.

No Claude Code, inicie-o com o `run_in_background` da ferramenta Bash, na
mesma mensagem que os subagentes dos outros eixos, para que rode junto com
eles. É um comando, não um subagente: nada de Agent em volta dele.

## O brief

Preencha o que está entre `< >`. No modo de plano, troque as linhas do
intervalo pelo texto do plano e pelas quatro perguntas da Revisão de plano
do `SKILL.md`.

```text
Você é um eixo de uma revisão rigorosa, no estilo de Linus Torvalds. Você
roda num sandbox só de leitura: não tente modificar nenhum arquivo. Este
brief é a tarefa inteira: não abra nem siga nenhuma skill, a
revisao-rigorosa incluída, e não rode `codex`.

Repositório: <caminho absoluto>
Mudança: rode `git diff <base>...HEAD` e `git log --oneline <base>..HEAD`;
leia os arquivos inteiros onde um hunk precisar do contexto.
Especificação: <caminho, texto colado ou "nenhuma">
Arquivos de normas: <lista de caminhos ou "nenhum">

Primeiro responda, sobre a mudança como um todo: É um problema real ou
imaginado? Há um jeito mais simples? O que ela quebra (quem chama o
código, dados guardados, interfaces públicas, fluxo de trabalho dos
usuários)?

Depois aponte cada achado:
- a quebra de uma norma documentada (dura), citando o arquivo e a regra;
- um item da base abaixo (questão de julgamento), nomeando-o;
- um requisito da especificação que falta, está pela metade ou foi
  implementado errado, citando a linha da especificação; comportamento
  que ninguém pediu;
- um defeito: um bug, uma regressão, uma assinatura ou valor de retorno
  alterado com quem o chama deixado para trás (procure na árvore quem o
  chama).

Cada achado: bloqueante ou não, `caminho:linha`, o hunk citado ao pé da
letra, por que está errado e o conserto. Nenhum achado sem uma linha que
você possa citar. Contexto que falta é pergunta, não achado. Não aponte o
que um linter ou formatador impõe.

Termine com o seu próprio veredito, numa linha só:
Veredito: Pronto para o merge | Não está pronto: <consertos, o mais importante primeiro>

Responda em <língua>, em menos de 600 palavras.

A base Linus:
<references/base-linus.md inteiro>
```

## Confira, depois relate

Trate `<dir>/codex-review.md` como o relatório de qualquer subagente: o
passo 5 roda sobre ele por inteiro. Reabra cada local citado e confira
cada hunk citado contra o diff, palavra por palavra; uma citação que o
diff não contém, ou uma linha que não diz o que o Codex afirma, descarta o
achado. O Codex não sabe nada dos outros eixos, e os achados dele não se
conferem contra os deles: um achado que só o Codex levantou e que
sobrevive à conferência conta como qualquer outro. Uma chamada é uma
amostra: duas rodadas do mesmo brief sobre o mesmo commit, em 2026-10-26,
devolveram dois achados bloqueantes e depois um deles. Um relatório limpo
do Codex não prova que a mudança está limpa.

Sob `## Codex`, primeiro uma linha: modelo, esforço, `codex --version`,
quantos achados voltaram e quantos caíram na conferência. Depois os
achados que sobraram, por gravidade.

Quando o eixo não rodou, `## Codex` diz só isso e por quê: `codex` não
instalado, não logado, ou a chamada falhou (o código de saída e a
primeira linha `ERROR:` do log, ou um arquivo `-o` ausente ou vazio; um
modelo que a conta não serve sai com 1 e `model_not_found` e não escreve
o arquivo `-o`). Uma rodada ainda em curso quando os outros eixos já
terminaram e foram conferidos ganha mais cinco minutos, depois é parada e
conta como falha. Nunca escreva pelo Codex achados ou veredito que a saída
dele não contenha.

## No veredito

Duas linhas, depois do veredito em si:

```
Provedores: Claude (<modelo>) + Codex (<modelo>, <esforço>, codex-cli <versão>)
Divergência: <os achados bloqueantes que só um provedor levantou, e o veredito do Codex quando difere deste; ou "nenhuma">
```

Um achado bloqueante conferido bloqueia o merge, seja quem for que o
levantou; a linha Divergência mostra onde os dois modelos viram coisas
diferentes, ela não anula o veredito. Quando o Codex não rodou:
`Provedores: só Claude (<modelo>) — Codex <motivo>`, e nenhuma linha
Divergência.
