---
name: revisao-rigorosa
description: >-
  Revisão rigorosa, à Linus Torvalds, de código ou de plano técnico:
  estruturas de dados primeiro, casos especiais eliminados por
  representação melhor, complexidade à altura do problema e nunca quebrar
  quem já usa. Revisa um diff em eixos separados (Normas, Especificação,
  História), em subagentes paralelos, para um não mascarar outro, mais um
  eixo cego noutro provedor (Codex CLI da OpenAI, só leitura), se
  instalado, e dá um veredito de merge.
  Use quando pedirem revisão no estilo Linus, dura, rigorosa ou franca;
  pedirem para revisar um ramo, um pull request, mudanças em andamento ou
  "revise desde X"; perguntarem se um plano técnico ou design se sustenta;
  ou num portão de revisão antes do push ou do PR.
  Também em inglês: "linus-review", "linus review", "strict review",
  "review this branch".
---

# Revisão rigorosa

Revise a mudança como a revisaria um mantenedor que vai conviver com ela
por uma década. Programadores ruins se preocupam com o código; bons
programadores se preocupam com as estruturas de dados e as relações entre
elas. Comece por aí.

## Tom

- Duro com o código, nunca com a pessoa. Diga por que algo está errado e
  qual é o conserto. Sem insultos, sem palavrões, sem frases feitas de
  rejeição.
- Calibre pela evidência. Onde o diff prova um defeito, diga-o sem
  "talvez". Onde você está inferindo, diga o que precisaria para
  confirmar.
- Reconheça o código bom, em poucas palavras, quando o vir. O mantenedor
  que só reclama é ignorado.
- Nunca especule para tapar um buraco. Contexto que falta é pergunta, não
  achado.
- Responda na língua do usuário, salvo se ele pedir outra.

## Primeiro, três perguntas

Antes de qualquer detalhe, responda estas sobre a mudança como um todo:

1. **É um problema real ou imaginado?** Rejeite maquinaria construída para
   uma ameaça que ninguém viu.
2. **Há um jeito mais simples?** A menor mudança que é obviamente correta
   vence a engenhosa.
3. **O que ela quebra?** Contam quem já chama o código, os dados
   guardados, as interfaces públicas e o fluxo de trabalho dos usuários.
   Uma regressão é um bug, por mais limpa que seja a teoria.

Se a resposta à primeira pergunta for "imaginado", o veredito já se sabe.
Diga-o e pare antes da passada detalhada.

## Modo

- **Revisão de código:** há um diff, um ramo ou um pull request. Siga o
  [Processo da revisão de código](#processo-da-revisão-de-código).
- **Revisão de plano:** há um design ou um plano e ainda nenhum código.
  Siga a [Revisão de plano](#revisão-de-plano).

Se o pedido for ambíguo ("dá uma olhada nisto"), pergunte qual dos dois o
usuário quer.

## Processo da revisão de código

### 1. Fixe o ponto de partida

Use o commit, o ramo, a tag ou o intervalo que o usuário nomear. Se ele
disser "este ramo" ou "antes de eu fazer o push", use o merge-base com o
ramo principal. Se nada identificar a base, pergunte.

Registre uma vez o comando do diff, com três pontos para comparar com o
merge-base, e a lista de commits:

```bash
git diff <base>...HEAD
git log --oneline <base>..HEAD
```

Confirme que a base resolve (`git rev-parse <base>`) e que o diff não está
vazio. Uma referência errada tem de falhar aqui, não dentro de subagentes
paralelos. Quando o usuário perguntar pelo trabalho não commitado, inclua
também `git diff HEAD`.

### 2. Encontre a especificação

Procure o que a mudança devia fazer, nesta ordem:

1. Um caminho ou link que o usuário passou.
2. Referências a issues nas mensagens de commit (`#123`, `Closes #45`).
3. A descrição do pull request (`gh pr view --json title,body`).
4. Um plano, especificação ou documento de design no repositório cujo nome
   bata com o ramo ou com a funcionalidade.

Se nada aparecer, pergunte uma vez. Se o usuário disser que não há
especificação, pule o eixo Especificação e diga-o no relatório.

### 3. Encontre as normas

Reúna o que o repositório documenta sobre como o código deve ser escrito:
os arquivos de instruções para agentes (`AGENTS.md`, `CLAUDE.md`), o
`CONTRIBUTING.md` e os documentos de estilo, de testes, de revisão ou de
arquitetura. Pule o que um linter, um formatador ou um verificador de
tipos já impõe.

Além deles, o eixo Normas leva sempre a **base Linus**, em
[references/base-linus.md](references/base-linus.md). Duas regras a
limitam:

- **O repositório prevalece.** Uma norma documentada do repositório vence;
  onde ela endossa algo que a base apontaria, retire o item da base.
- **Os itens da base são questões de julgamento.** Rotule-os como tais
  ("possível insanidade de caso especial"), nunca como violações duras. Só
  a quebra de uma norma documentada pode ser dura.

### 4. Rode os eixos em paralelo

Abra um subagente por eixo, todos de uma vez, para que os contextos fiquem
separados. Cada prompt tem de se bastar: o subagente não vê mais nada.

**Modelo.** Todo eixo roda no mesmo modelo fixo, seja qual for o modelo da
sessão principal: o modelo mais forte do provedor abaixo do carro-chefe,
nunca o menor. No Claude Code, passe `model: "opus"` à ferramenta Agent em
cada eixo (Claude Opus 5.5 em 2026-10-24). Com outro harness ou outro
provedor, escolha o mesmo nível pelo nome; com modelos locais, o mais
forte que responda em velocidade interativa. O subagente que herda o
modelo herda o carro-chefe quando a sessão roda nele, o que custa mais e
roda mais devagar do que uma revisão precisa. O menor nível não dá conta:
medido em 2026-10-24 sobre quatro ramos já juntados de um repositório
(código de aplicação, ferramentas em Python, instruções para agentes,
ferramentas de LaTeX), 48 rodadas dos quatro eixos contra os defeitos que
a revisão original tinha consertado, o Claude Haiku 4.5 achou 3 de 39, com
evidência inventada e checagens que impunham o próprio nome no trailer de
atribuição; o Claude Sonnet 5.5 achou 25 e o Claude Opus 5.5 achou 32,5, à
frente nos quatro eixos, mais em Especificação e História, por no máximo
11% mais tokens.

**Normas.** Dê a ele o comando do diff, a lista de commits, a lista dos
arquivos de normas e o texto inteiro da base Linus colado. Brief: "Aponte
cada lugar em que o diff viola uma norma documentada, citando o arquivo e
a regra, e cada item da base que você notar, nomeando-o e citando o hunk.
Marque as quebras de norma documentada como duras e os itens da base como
questões de julgamento. Pule o que as ferramentas impõem. Cite
`caminho:linha` em cada achado. Menos de 400 palavras."

**Especificação.** Dê a ele o comando do diff, a lista de commits e a
especificação (o caminho ou o texto buscado). Brief: "Aponte (a) os
requisitos que a especificação pede e que faltam ou estão pela metade,
(b) o comportamento no diff que ninguém pediu e (c) os requisitos que
parecem implementados, mas cuja implementação parece errada. Cite a linha
da especificação e `caminho:linha` em cada achado. Menos de 400 palavras."

**História.** Só quando o intervalo tem commits. Dê a ele a lista de
commits, as regras sobre commits que os arquivos de normas trazem, e
mande-o ler cada commit com `git show`. Brief: "Para cada commit,
aponte (a) mais de uma mudança lógica num commit, quando as partes se
separam de forma limpa: cada commit da divisão é o seu pai mais linhas do
diff final, e compila e passa nos próprios testes. Nomeie os commits em
que você o dividiria. Partes que compartilham uma mesma reestruturação, em
que um commit intermediário precisaria de código que não está nem no pai
nem na ponta, podem ficar num commit só quando a mensagem diz por que vão
juntas. (b) Movimentação, renomeação ou reformatação que esconde a lógica:
mesmo com as opções do diff que olham através dela (`-w`,
`--color-moved`, `--word-diff`), o leitor tem de ler as linhas mecânicas
para achar a mudança; ou uma reformatação ampla feita por uma ferramenta
divide um commit com lógica, e um arquivo de blame-ignore não consegue
pulá-la sem pular a lógica. Uma renomeação local, uma quebra de linha que
a edição força e uma renomeação que acompanha uma mudança no contrato da
mesma função ficam com a mudança. Onde as regras do repositório pedem
cada movimento num commit próprio, aponte qualquer mistura. (c) Um
problema que um commit introduz e um commit posterior conserta. (d) Uma
mensagem que descreve o diff em vez de explicar o porquê: sem enunciar o problema, sem a razão
deste conserto, sem teste nomeado, sem a razão de as partes de um commit
mantido inteiro irem juntas. (e) Um banner de IA ou menção a ferramenta no
assunto ou no corpo, a menos que as regras do repositório o peçam ali;
uma linha de banner sozinha, logo acima do bloco de trailers, é onde a
skill `mensagem-de-commit` põe a que um harness de agente fornece, e não
é achado. Cite o sha curto do commit. Menos de 300 palavras." Quando a
skill `mensagem-de-commit` estiver instalada, aponte-a ao subagente como a
norma de (d). Num ramo que ainda não chegou ao ramo principal e em que
ninguém mais se apoia, o remédio para (c) é dobrar o commit posterior no
que ele conserta, não manter os dois; diga-o no achado. Num ramo em que
outros se apoiam, o commit posterior fica, e a mensagem dele nomeia o
commit que ele conserta.

**Fatos.** Só quando o intervalo tem commits e a skill
`checagem-de-fatos` está instalada. Dê a ele o brief do cartucho de
mensagem de commit, que mora na skill `mensagem-de-commit`
(`cartuchos-de-fatos/mensagem-de-commit.md`, "O brief do subagente"),
com o intervalo e o
repositório preenchidos. Ele confere contra a árvore cada fato que as
mensagens afirmam: um sha citado e o que ele fez, um caminho e o que ele
diz, uma regra citada de um arquivo de instruções e o verbo dela, uma
contagem, uma data, "só comentário". A História fica com (a)–(e) e não
confere os fatos de novo. Uma mensagem no ramo principal nunca se
reescreve, então este eixo é a última chance de consertar um fato errado
com um amend ou um fixup.

**Codex.** Um segundo provedor de modelo, para que a revisão não dependa
de um modelo só. Siga [references/codex.md](references/codex.md): confira
que o `codex` está instalado e logado, escreva o brief dele (as três
perguntas, as normas, a especificação, a base Linus, o intervalo) num
arquivo e rode `codex exec --sandbox read-only` sobre ele em segundo
plano, junto com os subagentes. Ele é cego: não lhe diga nada do que os
outros eixos acham. Se o `codex` faltar, não estiver logado ou a chamada
falhar, a revisão segue com um provedor e o diz; nunca escreva um
resultado que o Codex não devolveu.

Se não houver ferramenta de subagente, rode os eixos um depois do outro e
mantenha as notas de cada eixo separadas até o relatório.

### 5. Confira antes de relatar

Reabra cada local citado. Descarte todo achado que você não consiga
ancorar numa linha, num hunk ou numa frase citada da especificação. Para
cada mudança de comportamento, percorra à mão o caso que falha no código
antigo e no novo. Para cada assinatura ou valor de retorno alterado,
procure na árvore todos os que o chamam.

### 6. Relate

Apresente cada eixo sob o próprio título, com os achados em ordem de
gravidade dentro do eixo. Não junte nem reordene entre eixos: uma mudança
pode seguir todas as normas e implementar a coisa errada, ou fazer
exatamente o que se pediu e quebrar as convenções. Relatórios separados
impedem que um esconda o outro.

```
## Normas
## Especificação
## História
## Fatos
## Codex

## Veredito
Pronto para o merge | Não está pronto: <os consertos exigidos, o mais importante primeiro>
Provedores: Claude (<modelo>) + Codex (<modelo>, <esforço>, codex-cli <versão>)
Divergência: os achados bloqueantes que só um provedor levantou; o
veredito do Codex quando ele difere; ou "nenhuma"

Ideia central: a observação de estrutura de dados ou de design que mais importa.
Simplificação: a direção que elimina código ou casos especiais.
```

"Pronto com ressalvas" é "não está pronto". Diga o que tem de mudar.

Um achado do Codex que sobreviveu ao passo 5 conta como qualquer outro: um
achado bloqueante conferido bloqueia o merge, seja qual for o provedor que
o levantou. A linha Divergência mostra onde os dois modelos discordam; ela
não anula o veredito. Quando o Codex não rodou, a linha Provedores diz
"só Claude (<modelo>)" e por quê, e não há linha Divergência.

### 7. Condense antes do merge

Um ramo que ainda não chegou ao ramo principal, e sobre o qual ninguém mais
constrói, é rascunho. Quando o veredito for Pronto para o merge, leia a
lista de commits dele como a história que ele vai deixar. Se ela carregar
o diário da revisão (commits que respondem a achados, uma regra reescrita
em vários commits, uma área consertada em rodadas), recomende condensá-lo
antes do merge:

- Dobre cada conserto no commit que ele conserta: `git commit
  --fixup=<sha>` durante as rodadas da revisão, depois
  `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>`; ou refaça a
  série à mão.
- Deixe uma mudança lógica por commit e reescreva cada mensagem a partir
  da árvore que ela agora descreve (a skill `mensagem-de-commit`): as
  rodadas da revisão, os achados que elas responderam e os shas da série
  rascunho não fazem parte da história.
- Guarde o sha da ponta revisada e confira que o ramo condensado termina
  na mesma árvore: `git diff <ponta-revisada> HEAD` tem de sair vazio.
  Rode de novo a autoconferência da `mensagem-de-commit` sobre cada
  mensagem reescrita, contra a árvore do próprio commit, não a da ponta.
  Depois, só os eixos História e Fatos rodam de novo, sobre a série nova:
  o rebase reescreveu as mensagens a partir da árvore e mudou os shas que
  elas citam, e uma mensagem reescrita nunca passa pelas ferramentas que a
  leem no comando `git commit`. Uma árvore diferente é código novo e leva
  a revisão inteira.
- O `git diff` vazio não prova nada sobre os commits do meio. Uma série
  refeita à mão (um arquivo dividido entre commits, hunks movidos) pode
  quebrar um commit intermediário que um posterior conserta: cortar um
  arquivo a partir da ponta levou junto a linha em branco antes do título
  seguinte, e o commit mais antigo deixou o título colado ao parágrafo.
  Monte o arquivo intermediário a partir do pai mais os hunks, não da
  ponta menos o que sai, e leia cada commit atrás de linhas em branco
  acrescentadas ou removidas:
  `git show --format= <sha> -- <arquivo> | grep '^[-+]$'`.
- Uma mensagem reescrita pelo editor (`git commit --amend` sem `-F`, o
  `reword` do `git rebase -i`, mesmo com `GIT_EDITOR` apontando para um
  script que copia um arquivo) é limpa com `strip`, que descarta toda linha
  que começa com o `core.commentChar` (`#`): um título de Markdown, um
  `#123` no começo da linha. O `git commit -F` as mantém. Reescreva com
  `git commit --amend -F <arquivo>`, ou não comece nenhuma linha com `#`;
  depois, compare `git log --format=%B <base>..HEAD | grep -n '^#'` com os
  arquivos das mensagens.

Pule este passo quando o repositório proibir reescrever um ramo não
juntado, ou quando o ramo já tiver ido por push para outros construírem
sobre ele. Nunca reescreva o que já está no ramo principal.

## Revisão de plano

Peça primeiro o contexto que falta: o problema, as restrições, as
interfaces tocadas e o caminho de volta. Depois julgue:

- **Modelo de dados e posse.** Qual é o dado central? Quem o cria, o
  altera e o lê? Algo é copiado ou convertido sem razão?
- **Casos especiais.** Que desvios existem só porque o modelo tem a forma
  errada? Outra representação pode eliminá-los?
- **Complexidade contra gravidade.** A maquinaria está à altura do
  tamanho do problema, ou é um framework para um caso isolado?
- **Compatibilidade e implantação.** Que comportamento, dado ou interface
  existente muda? Como se migra, e como se volta atrás?

Rode o eixo Codex sobre o plano também, com a variante de plano do brief
em [references/codex.md](references/codex.md), antes de escrever o seu
próprio julgamento, e confira os pontos dele contra o texto do plano do
mesmo jeito. Relate com o mesmo bloco de Veredito, linhas Provedores e
Divergência incluídas: vale a pena fazer ou não, e por quê.
