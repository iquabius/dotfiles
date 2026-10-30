# Cartucho: registros de decisão e notas do projeto

Cartucho de checagem de fatos do registro desta skill, a `adr`: o motor,
sem registro, é a skill `checagem-de-fatos`.

O artefato é um registro de decisão (um ADR: um parágrafo com data
absoluta, a decisão, o que ela substitui, "em vez de" e "custo") ou uma
nota do projeto (uma nota de referência, uma nota de achados, uma nota de
processo). Os dois prestam contas à verdade; a decisão em si e os motivos
dela são do autor e não se conferem pelo mérito, só pelos fatos em que se
apoiam.

## 1. Artefato e âncora

`file:line` do ADR ou da nota no commit lido. Uma nota com seções datadas
se confere seção a seção, cada uma contra a data que leva.

## 2. Fonte primária e a escada

**Primária:**

- o repositório na data que o ADR ou a seção leva: o arquivo, a pasta, a
  configuração que ele descreve (`git show <commit-at-date>:<path>`);
- o glossário do projeto (`GLOSSARY.md` ou o equivalente) para cada
  termo, na entrada;
- a decisão anterior que o ADR substitui ou cita: o texto desse ADR no
  git na época (`git log -p -- docs/adr/<n>-*.md`), não a lembrança dele;
- um commit ou uma tarefa que o texto cita: o diff, o registro;
- um fato externo com data (uma versão, um número de downloads, um
  benchmark, uma declaração de um fornecedor): a página ou o documento da
  própria fonte, com a data em que foi observado, como a convenção da
  nota o registra.

**Corroboração:** outra nota do projeto que traz o mesmo fato datado com
a sua própria fonte; as notas da tarefa.

**Nunca sozinhos:** a conversa que produziu a decisão, o resumo que um
ADR posterior faz de um anterior, a lembrança que o autor tem de um
número.

## 3. Categorias de afirmação

- **data**: absoluta, e a certa (a da decisão, não a do commit, quando
  diferem);
- **a alternativa**: ela existia e era possível neste projeto naquela
  data; um "em vez de" que nunca esteve na mesa é enfeite;
- **o custo**: um fato sobre o que a decisão abre mão, não uma
  esperança;
- **o termo**: uma palavra por conceito, contra a entrada do glossário e
  a lista de "evitar" dela;
- **o conteúdo da decisão anterior**: citado do git na época, quando o
  ADR diz o que substitui;
- **número, versão, nome**: o fato externo datado, com a fonte;
- **a afirmação sobre o repositório**: "X mora em Y", "o script faz Z",
  na data.

## 4. A cadeia

**Decisão ← motivo ← alternativa ← custo.** Audite: um motivo que
contradiz outro ADR ainda em vigor; um custo que a alternativa também
pagaria (então não é custo desta decisão); uma decisão cujo motivo se
apoia num fato externo que mudou desde então (a convenção da nota diz que
cada fato assim leva a data em que foi observado; a checagem relata os
vencidos, e o autor decide se a decisão fica de pé).

## 5. O que vira a afirmação sem fonte

A convenção do projeto: um fato datado sem fonte ganha "não conferido,
observado em <data>" ou se pergunta ao autor; um termo fora do glossário
vira uma pergunta de glossário (`domain-modeling`), não uma troca de nome
calada.

## 6. Correções e quem aprova

Um ADR que muda se reescreve no lugar, com a data nova e a decisão
anterior num "em vez de"; uma errata se corrige no texto. Correções de
fato (uma data, um sha, um termo) entram no diff que o autor revisa; uma
correção que muda o motivo da decisão é do autor decidir, com as
alternativas, antes de qualquer coisa se escrever.

## 7. Passadas e momento

Uma passada antes do commit que acrescenta ou reescreve o ADR ou a nota,
pelo agente autor, com o subagente só quando o artefato cita mais de ~30
fatos (uma nota de referência longa). Um portão mecânico, onde o
repositório tiver um, confere que a data é absoluta e que os números de
ADR, os shas e os ids de tarefa citados existem.

## 8. Lotes e modelo

Um subagente para o artefato inteiro; lotes de 4–8 só para uma nota de
referência longa, divididos por fonte. Onde o subagente roda, o Codex
roda ao lado dele com as mesmas afirmações (SKILL.md da
`checagem-de-fatos`, "O segundo
provedor: Codex").

## 9. Onde fica o relatório e em que língua

Na conversa, por `file:line`, cada correção como o texto exato a trocar.
A língua é a da documentação do projeto.
