---
name: revisao-de-usabilidade
description: >-
  Revisa tela, fluxo, gráfico ou texto de produto como um especialista
  em usabilidade, em nome de um usuário leigo: portões primeiro (beco sem
  saída, dano irreversível, piso de acessibilidade), depois seis lentes
  em separado (usabilidade de Nielsen e Krug, ergonomia e hierarquia
  medidas em pixels, texto lido em voz alta, dados, persuasão contra
  padrões obscuros, estados), com achados graduados e citados, conserto
  em Antes / Depois / Por quê, veredito por faixa e um "corrija isto
  primeiro". Use quando pedirem revisão ou crítica de design ou UX,
  auditoria de usabilidade, avaliação heurística, revisão de rótulos,
  microcopy ou gráfico numa tela ou de hierarquia visual, ou o julgamento
  de uma tela antes de mexer num controle, mesmo que chamem de "revisão
  Linus" de uma tela; diff, código ou plano técnico: revisao-rigorosa.
  Não escreve textos nem desenha telas; não serve para escolha entre
  opções (matriz-de-decisao) nem oficina de texto longo (banca).
  Também em inglês: "design-review", "UX review", "usability audit".
---

# Revisão de usabilidade

Revise um design como o faria um especialista em usabilidade se quem o usa
fosse o leitor menos capaz que o produto ainda promete atender. Os achados
são evidência que se pode apontar, com a citação de uma heurística ou
critério nomeado, graduada conforme o que você de fato sabe e fechada com um
conserto cirúrgico. Gosto sem um ponteiro não é achado.

## O que esta skill é, e o que não é

Quatro instrumentos dividem o trabalho de revisão. Mantenha-os separados,
porque cada um responde a uma pergunta e se embaralha no momento em que
responde a duas:

| Instrumento | Pergunta que responde | Mande para lá quando |
|---|---|---|
| **revisao-de-usabilidade** (esta) | Esta tela, fluxo, gráfico ou texto é usável pela persona, honesto e coerente com o que o produto já ensina? | existe um design e ele precisa ser provado |
| `revisao-rigorosa` | Este diff ou plano está correto, é simples e seguro para quem já usa? | um achado acaba sendo sobre estrutura de código, fluxo de dados, testes ou um plano |
| `matriz-de-decisao` | Qual de N opções, e com que evidência? | a revisão acha uma bifurcação real entre alternativas |
| `banca` | Este texto que já existe sobrevive a um painel adversarial? | um texto longo ou disputado precisa de oficina linha a linha |

Observações de código que aparecem durante uma revisão de usabilidade (um
ciclo de imports, uma fonte da verdade duplicada no store, um teste que
confere chamadas em vez de resultados) são **encaminhadas**, nunca julgadas
aqui. Duas ideias que migraram da revisão de código para o design moram
aqui com nomes próprios, para deixarem de ser "Linus": **fonte única da
verdade na tela** (um número mora num lugar só; todo o resto ecoa a direção
dele) e **um padrão, não N variantes** (um caso especial na interface é um
mau cheiro de design exatamente como é no código).

## Antes da primeira passada

As referências são curtas. Leia `references/personas.md`,
`references/checagens.md` e `references/relatorio.md` antes do Passo 0,
`references/acessibilidade.md` antes do Passo 1, e cada arquivo de lente
antes de rodar aquela lente. Carregue `references/conflitos.md` quando
dois cartões se contradisserem; a seção "Cenários comuns" também pode ser
lida sem disputa. É o procedimento de desempate, não uma lente. O
`THIRD_PARTY_NOTICES.md` é uma obrigação de licença, nunca conteúdo de
revisão.

## Voz

Neutra por padrão: os achados se leem como evidência sobre a qual um
designer, alguém da casa ou o dono do produto pode agir sem tradução. Uma
**camada de voz** (Linus, ou outra que o usuário nomear) pode ser ligada a
cada pedido; ela reescreve só o tom. Severidades, graus, citações, textos
citados e o veredito passam intocados por todas as vozes. Uma frase dura que
você não consegue sustentar com um cartão de achado é grosseria, não
revisão. A voz nunca se guarda como preferência permanente, porque uma voz
guardada vaza para artefatos de gente que não a pediu. Responda na língua
do usuário; os IDs das checagens e os graus de evidência ficam como estão
escritos aqui, seja qual for a língua, para que os relatórios se busquem e
se comparem entre línguas.

## Passo 0 — Escopo, superfície, persona, tarefa

Antes de olhar qualquer coisa, fixe quatro coisas. Uma revisão sem elas
deriva para o gosto.

1. **O que está em revisão.** Uma tela, um fluxo de telas, a mudança de um
   controle, um gráfico, um trecho de texto. Se o usuário diz "olha isto",
   pergunte qual, uma vez. **Camadas da primeira visita** (um tour,
   uma dica flutuante) fazem parte da tela para quem chega pela primeira
   vez: revise a tela em repouso com elas fechadas, e uma vez a frio com
   elas abertas; a passada a frio vai para o apêndice, a menos que falhe
   num portão.
2. **A superfície.** Viewport e classe de aparelho, tema, e se você tem o
   app renderizado, uma captura de tela ou um arquivo de design. A
   superfície móvel padrão é 375×812 px CSS com razão de pixels 3, com
   emulação de celular e de toque: um celular pequeno, como o iPhone X,
   para que os achados de alcance e de tamanho errem pelo lado do caso
   mais difícil. Emule o aparelho, não o tamanho da janela. Achados sobre
   alcance e oclusão não significam nada sem a superfície declarada.
3. **A persona e o lugar.** Carregue `references/personas.md`. O padrão é a
   persona ingênua (o Novato, ou a Novata): alguém leigo, na primeira vez,
   encontrando a tela a frio. Num produto de vários usuários, o usuário pode
   restringir a revisão a um **lugar**; essa restrição vence, e os outros
   lugares que têm uma ação na tela vão para "Não avaliado", pelo nome.
4. **A tarefa.** O que a persona veio fazer aqui, nas palavras dela? O
   usuário a dá. Se não deu, proponha uma, marque-a como suposição sua no
   topo do relatório e siga; uma revisão sem tarefa é questão de humor.

Registre as quatro no topo do relatório.

## Passo 1 — Portões

Antes de conferir os portões, faça a passada de medição descrita no
Passo 2; use os artefatos dela aqui. Confira os portões antes de qualquer
lente: um design que falha num portão não ganha uma nota matizada; ganha o
veredito Alto risco, com a falha como motivo. A revisão não para aí: rode
todas as lentes aplicáveis e relate os achados embaixo. Os IDs dos portões
e os limites deles são canônicos em
`references/checagens.md` (seção dos portões) e
`references/acessibilidade.md`; esta lista os nomeia.

- **`BECO-SEM-SAIDA`.** O caminho da tarefa chega a um estado sem nova
  tentativa, sem saída e sem próximo passo: as três ausências juntas.
  Julgue o **caminho que ela veio fazer**, não
  a tela inteira: uma tela com uma barra de abas que funciona ainda é beco
  sem saída se o fluxo de ajuda termina num estado de que ela não consegue
  sair nem tentar de novo. Confira o **caminho humano**: um interlocutor
  roteirizado ou de demonstração que responde na hora mascara o estado em
  que uma pessoa de verdade ficaria esperando, então leia o código ou o
  design atrás do estado que a demonstração pula.
- **`IRREVERSIVEL`.** Uma perda, cobrança, envio ou atribuição sem desfazer
  e sem escolha *consciente*. Consciente quer dizer que ela sabe o que a
  ação faz, e a quem, antes de fazê-la.
- **O piso de acessibilidade**: a tabela completa está em
  `references/acessibilidade.md`; os IDs `TAMANHO-DO-ALVO`, `CONTRASTE`,
  `SO-COR` e `TAMANHO-DO-TEXTO` cobrem parte dela. Texto corrido é o texto
  necessário à tarefa: frases, rótulos de ação e de campo, status,
  mensagens de erro, eixos e legendas. Etiquetas de metadados, carimbos de
  hora e rótulos de abas recebem nota, não portão; abas são a exceção entre
  os rótulos de ação.
- **Portões do domínio**, declarados **antes** de as lentes rodarem:
  conferíveis de modo binário, ligados a um inegociável declarado,
  conferíveis física ou contratualmente. `TEXTO-TRANSBORDA` é o modelo (o
  texto transborda com o comprimento típico dos valores que preenchem os
  campos variáveis). Propor um portão depois que os cartões existem é inflar
  portões: é inventar um critério eliminatório para matar um design de que
  alguém não gosta; recuse a proposta e deixe a preocupação virar um cartão
  de severidade máxima. O mesmo vale para um beco sem saída descoberto só
  depois que as lentes rodaram: ele é o primeiro cartão, não um portão
  retroativo.

A falha num portão vem primeiro no relatório, como o motivo do veredito.

## Passo 2 — Lentes, em separado

Rode cada lente numa passada própria, para que um achado barulhento numa
não esconda um silencioso noutra.

**Um só segura o navegador.** Um app ao vivo guarda estado: o toque de uma
lente muda o que outra vê. Antes do Passo 1, o orquestrador roda uma única
**passada de medição**: fixa a superfície, percorre os estados de que a
tarefa precisa (em repouso, depois de cada ação, estados de erro e vazio,
primeira visita a frio), captura os retângulos e as capturas de tela em cada
um, e lê o código atrás dos estados que a demonstração pula. Depois as
lentes rodam sobre os artefatos capturados e o código. Quando houver
ferramenta de subagentes, lance um agente só de leitura por lente com um
pedido que se baste (a superfície, a persona, o lugar, a tarefa, os
retângulos e as capturas, os caminhos do código e o arquivo da lente).
Exceção: para a leitura a frio, o agente da lente de texto recebe só a
tarefa e o texto citado, sem código nem intenção da equipe. Consolide uma
vez. Sem subagentes, rode as passadas uma depois da outra e mantenha as
notas separadas até o relatório.

| Lente | Lê | Referência |
|---|---|---|
| **Usabilidade** | as dez heurísticas de Nielsen, as leis de Krug e o teste do porta-malas, o diagnóstico rápido | `references/heuristicas.md` |
| **Ergonomia e hierarquia** | zona do polegar, oclusão por barras sticky, tamanho dos alvos, uma ação primária, teste de apertar os olhos, ordem das seções | `references/ergonomia.md` |
| **Texto** | leitura em voz alta como a persona, calibragem das afirmações, pessoa gramatical e registro, um termo por conceito, o título é dono do número, caber no layout | `references/texto.md` |
| **Exibição de dados** | o gráfico certo para a forma dos dados, falsos zeros, horizontes de tempo misturados, ranking onde o assunto é justiça | `references/exibicao-de-dados.md` |
| **Persuasão** | empurrão ou padrão obscuro, confirmshaming, falsa urgência, desvio de atenção | `references/persuasao.md` |
| **Estados** | vazio, carregando, erro, sucesso, desabilitado; o que acontece quando a lista está vazia, a ação falha, o outro lado diz não | `references/heuristicas.md` (seção Estados) |

Pule uma lente só quando o artefato não lhe dá nada para ler (uma revisão só
de texto não tem passada de ergonomia; uma tela sem números não tem passada
de exibição de dados) e diga isso no relatório. Um formulário que pede
dados ou consentimento sempre carrega `persuasao.md`, mesmo só em texto;
a lente avalia apenas o que o texto mostra. Nos demais casos, não carregue
`persuasao.md` nem `exibicao-de-dados.md` se não houver nada para eles.

**Meça quando puder.** Afirmações de ergonomia e hierarquia vêm com pixels:
com uma ferramenta de navegador ou DevTools à mão, a passada de medição pega
os retângulos dos elementos, e os achados calculam a partir deles o alcance,
a oclusão e o tamanho dos alvos (protocolo em `references/ergonomia.md`; a
receita do contraste, em `references/acessibilidade.md`). Sem essa
ferramenta, o achado sai mesmo assim, graduado `[Julgamento]`, e diz que não
foi medido. Para portões, esse grau vira "medição pendente" em "Não
avaliado", sem reprovação. A medição é o que separa uma revisão de uma
opinião; é também o que produziu os melhores achados na jurisprudência
desta skill.

## Passo 3 — O cartão de achado

Prosa narrada não conta. Todo achado é um cartão com estes campos (modelo em
`references/relatorio.md`):

- **ID da checagem**, de `references/checagens.md` (por exemplo
  `ENCOBERTO`, `LEITURA-EMPACA`, `NUMERO-DUPLICADO`), ou `NOVO:<nome>` quando
  nenhum serve. Se um `NOVO` se repetir nesta revisão, sugira sua promoção
  em "Encaminhamentos"; quem mantém a skill decide e edita o arquivo.
- **Onde.** Um seletor, um retângulo medido na superfície declarada, ou o
  texto citado literalmente. Uma citação que não se acha de novo no artefato
  mata o cartão.
- **O que está errado**, especificamente, e **o que isso custa à persona**,
  nas palavras dela.
- **Citação.** O número da heurística, o critério WCAG, a lei ou a
  referência que faz disto um achado e não uma preferência. Um cartão sem
  ela é um palpite, e a linha de citação diz isso.
- **Severidade 0–4** (a escala de Nielsen), qualificada por frequência,
  impacto e persistência.
- **Grau de evidência.** `[Medido]` instrumentado · `[Observado]` visto
  numa sessão real ou numa renderização real · `[Julgamento]` um juízo de
  especialista, contestável mas que se pode apontar, inclusive um estado que
  você só leu no código · `[Afirmado]` sem respaldo. O grau é honesto sobre
  o que você fez, não sobre o quanto você se sente seguro.
- **Conserto em Antes / Depois / Por quê.** O estado atual, o estado
  proposto e o motivo, uma linha cada. Nomeie a operação (renomear, mover,
  juntar, dividir, remover, medir, reescrever). Para rótulos, o "Depois" é
  uma proposta mínima por rótulo, não a redação do texto final.

Descarte todo cartão que só parafraseia a tela de volta. Teste: tire o
elemento citado; a "análise" ainda diz alguma coisa?

## Passo 4 — Confira

Reabra todo local citado. Meça de novo todo retângulo que você relata. Ache
de novo toda citação, byte a byte. Liste o que você **não conseguiu
avaliar** (ordem do foco do teclado, anúncio do leitor de tela,
preferências de movimento, tempos reais, os lugares que mandaram pular) em
vez de adivinhar. Descarte o que não conseguir ancorar.

## Passo 5 — Relatório

Veredito na primeira seção, após o cabeçalho, depois a única coisa a
corrigir primeiro, depois no máximo seis achados em ordem de severidade,
depois o que manter, depois o que não pôde ser avaliado, depois os
encaminhamentos. Modelo em
`references/relatorio.md`.

- **Faixas do veredito:** **Alto risco** (qualquer falha de portão, ou
  qualquer cartão de severidade 4) · **Precisa de trabalho** (qualquer
  cartão de severidade 3, ou três ou mais de severidade 2) · **Sólido**
  (nada acima de severidade 2, e menos de três em 2). A faixa segue os
  cartões; nunca ajuste cartões para chegar a uma faixa.
- **Corrija isto primeiro** é a única mudança que fecha mais portões ou
  move mais a faixa. Quando vários portões independentes falham, diga isso
  e nomeie a mudança de efeito mais largo.
- **Limite a lista.** Seis achados são o orçamento do leitor. Tudo além de
  seis vai para uma linha no apêndice, não para o corpo. "Nenhum achado" é
  um resultado válido e se relata como tal, com o que foi conferido.
- **Manter.** Nomeie o que funciona e não pode ser tocado pelos consertos.
  Uma revisão que só reclama é ignorada, e os consertos, de outro modo,
  atropelam as partes boas.
- **Encaminhamentos.** Achados de código para a `revisao-rigorosa`; uma
  bifurcação genuína entre alternativas para a `matriz-de-decisao` (os
  cartões deste relatório viram as células de evidência dela); texto longo
  disputado para a `banca`.

## Passo 6 — Registro de decisão, oferecido

Quando a revisão muda uma decisão que o produto já tinha tomado (um controle
muda de lugar, um termo é aposentado, um tipo de gráfico vira), ofereça o
registro de decisão em uma linha no último espaço do relatório: a decisão,
quem decidiu (o D), a data, o artefato, o fator decisivo e qualquer decisão
contrária à recomendação desta revisão. Ofereça; nunca o escreva no log do
projeto sem pedido. A revisão recomenda; uma pessoa com nome decide, e uma
recomendação contrariada é o sistema funcionando, não uma falha de
persuasão.

## Nunca

- Nunca relate uma preferência como achado: sem citação, sem cartão.
- Nunca afirme uma medição que você não fez; gradue-a `[Julgamento]`.
- Nunca deixe o achado barulhento de uma lente tomar o lugar da passada de
  outra.
- Nunca deixe uma camada de voz mudar uma severidade, um grau, uma citação
  ou a faixa.
- Nunca pontue um design que falhou num portão como se o portão fosse mais
  um achado, e nunca acrescente um portão depois que os cartões existem.
- Nunca revise código aqui, e nunca revise uma tela na `revisao-rigorosa`.
- Nunca decida. Recomende e devolva a decisão a quem decide (o D).

## Referências

- `references/personas.md` — o contrato da persona, a persona ingênua
  padrão, os lugares. Partilhado com a `matriz-de-decisao`.
- `references/heuristicas.md` — as dez de Nielsen, as leis de Krug e o
  teste do porta-malas, a lista dos estados, a escala de severidade, o
  diagnóstico rápido. Núcleo incorporado da `ux-heuristics` da wondelai
  (MIT; ver `THIRD_PARTY_NOTICES.md`).
- `references/ergonomia.md` — zona do polegar, hierarquia e o protocolo de
  medição.
- `references/acessibilidade.md` — os números do piso (canônicos), as
  falhas comuns, a receita do contraste e o que uma captura de tela não
  diz.
- `references/texto.md` — protocolo da leitura em voz alta, escada das
  afirmações, pessoa e registro, fonte única na tela, caber no layout, o
  cartucho da banca.
- `references/exibicao-de-dados.md` — a escolha do gráfico e as regras de
  honestidade para números na tela.
- `references/persuasao.md` — a fronteira entre empurrão e padrão obscuro, e
  a taxonomia.
- `references/conflitos.md` — quando dois cartões brigam: os fatores de
  contexto e as soluções que atendem aos dois. A seção "Cenários comuns"
  também pode ser lida sem disputa.
- `references/checagens.md` — IDs estáveis das checagens, portões primeiro.
- `references/relatorio.md` — o cartão, o modelo de relatório, as faixas, o
  modo de comparação, o espaço do registro de decisão.
