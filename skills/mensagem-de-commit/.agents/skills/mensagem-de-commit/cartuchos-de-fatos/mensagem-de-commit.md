# Cartucho: mensagens de commit contra o repositório

Cartucho de checagem de fatos do registro desta skill, a
`mensagem-de-commit`: o motor, sem registro, é a skill
`checagem-de-fatos`.

O artefato é uma mensagem de commit: um rascunho antes do `git commit`,
ou a série de um ramo ainda não juntado (`git log <base>..HEAD`, diff de
três pontos contra o merge-base). A mensagem inteira presta contas à
verdade: um assunto, uma descrição do problema, um motivo, uma
alternativa recusada, uma frase de escopo e um teste são, cada um, uma
afirmação sobre a árvore, e quem ler o `git log` anos depois não tem
outra fonte. A mensagem diz por quê; o diff diz o quê. Onde os dois
discordam, a mensagem está errada, nunca o diff.

Por que este cartucho existe: em 2026-10-17, dois ramos chegaram a um
ramo principal com mensagens que diziam que uma regra "exige" o que a
regra só pede que fique mínimo, e que atribuíam a um commit o que outro
tinha feito. Os dois foram pegos por um eixo da revisão depois do commit,
quando a regra do projeto contra reescrever a história revisada só
deixava uma errata numa mensagem posterior. A checagem tem de rodar
enquanto um amend ainda é livre.

## 1. Artefato e âncora

Uma mensagem se endereça pelo sha e pela linha na mensagem (`sha:line`);
um rascunho, por `draft:line`. Uma série se confere mensagem a mensagem,
em ordem, porque uma mensagem posterior pode citar uma anterior.

## 2. Fonte primária e a escada

**Primária, sempre preferida — o repositório na árvore do próprio
commit:**

- o que o commit fez: `git show <sha>` (`--stat`, depois o diff); para um
  rascunho, `git diff --staged` (ou `git diff` para `-a`, ou os caminhos
  nomeados na linha de comando);
- o que um arquivo dizia antes e diz depois: `git show <sha>^:<path>` e
  `git show <sha>:<path>`; para um rascunho, `git show HEAD:<path>` e
  `git show :<path>` (o índice);
- o que um commit **citado** fez: o diff dele (`git show <cited>`), nunca
  a mensagem. A mensagem do commit citado também pode estar errada; que
  commit introduziu ou tirou uma linha se acha com
  `git log --format=%h -S'<text>' -- <path>` ou
  `git log -L<start>,<end>:<path>`;
- uma regra citada ou parafraseada de um arquivo de instruções
  (`AGENTS.md`, `CONTRIBUTING.md`, um guia de estilo): a frase exata no
  arquivo na árvore do commit. O verbo é o fato: "exige", "proíbe",
  "pede", "prefere" são quatro afirmações diferentes;
- uma tarefa, ticket ou issue por id: o registro dela no rastreador de
  tarefas (o comando do rastreador que mostra a tarefa pelo id,
  `gh issue view <n>`), no campo que a mensagem parafraseia. O registro é
  primário só para o que a própria tarefa é: título, estado, critérios de
  aceitação, motivo do fechamento. Um fato que o corpo dela afirma sobre
  outra coisa (o nome de um autor, uma página, um sha, o que um arquivo
  diz) é cópia, e se confere na fonte dele como qualquer outro;
- uma fonte citada por autor e ano ("Britton e Kutar (2001, p. 267)"): a
  entrada da bibliografia do repositório (um arquivo `.bib`: o campo
  `author`, cada sobrenome em ordem, e o `date` ou `year`) e, onde o
  repositório guardar um, o arquivo de trechos dessa chave, para a página
  e as palavras citadas;
- um registro de decisão por número: o arquivo (`docs/adr/<n>-*.md`), na
  frase;
- um teste, uma verificação ou uma contagem ("passa nas 23
  verificações", "cinco interfaces"): a saída do comando em mãos agora,
  ou o arquivo que define a contagem (`grep -c`); "capturas sem mudança",
  "só comentário", "nenhuma mudança funcional": `git show --stat`, o diff
  lido atrás de trechos que não sejam comentário, a saída do comando de
  conformidade;
- uma data ou um "desde": a data do próprio commit
  (`git log -1 --format=%ad`), a linha datada no arquivo.

**Corroboração:**

- um achado de revisão que a mensagem menciona ("achado do eixo
  História"): o relatório da revisão não está no repositório, então o
  fato que o achado estabeleceu tem de estar visível por si no diff ou na
  árvore; a procedência sozinha não prova nada;
- a mensagem do commit citado, só para confirmar o que o diff dele já
  mostra.

**Nunca sozinhos:** a memória do autor, a conversa que produziu a
mudança, o pedido que abriu a sessão e o corpo de uma tarefa ou ticket
(para qualquer fato que afirmem sobre outra coisa que não eles mesmos:
são cópias, e o sobrenome errado do anti-exemplo abaixo já estava no
corpo de uma tarefa), a mensagem anterior da mesma série, a linha de
assunto de um commit (assuntos resumem; o diff decide).

## 3. Categorias de afirmação

- **sha + o que ele fez**: "X entrou em 0abe102" — o diff de 0abe102 tem
  de mostrar X entrando; se ele só tirou um qualificativo, `git log -S`
  acha o commit que acrescentou X. Um sha do **mesmo ramo ainda não
  juntado** é alvo móvel: o rebase que condensa o muda. Depois do rebase,
  cada sha se confere de novo, e a mensagem que cita um commit do ramo
  cita ao lado o assunto dele entre aspas, como faz o trailer `Fixes:`;
- **caminho + o que ele diz ou faz**: o arquivo existe no commit, no pai
  (apagado ou renomeado por este commit) ou no disco (fora do git); o que
  ele "diz" é a frase na árvore do commit;
- **regra citada ou parafraseada**: o verbo e o escopo ("exige que o Lit
  tenha os métodos do Web Component" contra "pede que o par difira o
  mínimo");
- **contagem**: testes, verificações, interfaces, linhas, commits ("os
  quatro" que eram cinco);
- **nome, versão, opção, comando**: a opção que existe, o nome do script,
  a versão no arquivo de lock;
- **fonte citada por autor e ano**: cada sobrenome, em ordem, contra a
  entrada da bibliografia, o ano contra a data dela, a página e as
  palavras citadas contra o arquivo de trechos. Um nome que aparece
  também no corpo de uma tarefa ou no pedido da sessão se confere aqui
  como qualquer outro: no anti-exemplo abaixo, o sobrenome errado já
  estava no corpo da tarefa;
- **o assunto, lido sozinho**: como o `git log --oneline` o imprime, sem
  corpo para qualificá-lo. Um assunto que diz mais do que o commit fez é
  enganoso mesmo quando o corpo é exato ("Tira as oito dimensões
  deixadas de fora" para um commit em que as oito ficam na lista);
- **data, desde, até**: a linha datada, a data do commit;
- **história**: "introduzido em", "até", "o primeiro", "o único";
- **afirmação sobre a árvore**: "só comentário", "nenhuma mudança
  funcional", "capturas sem mudança", "o teste passa", "só estas linhas
  mudaram, o parágrafo não foi refluído";
- **descrição do problema**: o sintoma existe no pai
  (`git show <sha>^:<path>`, o caso que falha, o número errado);
- **alternativa recusada**: ela existia e era possível nesta árvore;
- **afirmação de escopo**: o que a mensagem diz estar fora do escopo de
  fato falta no diff, e o que o diff faz está na mensagem.

## 4. A cadeia

A forma da mensagem é a cadeia dela: **problema → por que este conserto
→ alternativa recusada → escopo → teste**. Audite:

- o problema é real no pai, dito como um fato sobre o código;
- o conserto que o diff faz é o conserto que a mensagem descreve, e não
  outro;
- o teste nomeado cobre o sintoma descrito (falha no pai, passa aqui);
- uma frase da mensagem que nenhum trecho do diff sustenta, e um trecho
  que nenhuma frase explica, quando um leitor esperaria uma;
- um commit posterior da série que corrige um anterior: o fato da
  mensagem anterior agora é falso, e a série é um rascunho a condensar (o
  achado é do eixo História da revisao-rigorosa; a checagem de Fatos
  relata o fato vencido).

Uma descrição do problema que volta **falsa** não é defeito da mensagem:
o commit pode estar resolvendo um problema que não existe. Ela vai para
o autor, não para uma reescrita da mensagem.

## 5. O que vira a afirmação sem fonte

Nunca uma marca: uma mensagem com "p. N" chega ao `git log` como está. A
frase enfraquece para o que o diff prova ("o teste novo mostra que
`load_prices()` devolve as duas linhas") ou sai (`mensagem-de-commit`,
"Todo fato tem fonte"). Um número que o autor tem e o agente não tem se
pergunta uma vez.

## 6. Correções e quem aprova

- **Rascunho**: reescreva antes do commit. O agente autor corrige o
  próprio rascunho sem perguntar; a regra do autor sobre quando um commit
  espera aprovação não muda.
- **Ramo ainda não juntado**: `--amend` na ponta, `--fixup=<sha>` para um
  commit anterior, depois o rebase que condensa; a árvore não muda
  (`git diff <reviewed-tip> HEAD` vazio), então só os eixos História e
  Fatos rodam de novo.
- **Enviado para outros**: nunca reescrito. A errata vai na próxima
  mensagem que tocar o assunto ("Errata de <sha>: …"), e a checagem vem
  mais cedo da próxima vez. A errata cita a frase velha e o fato certo, e
  a frase dela passa pelo momento 1 como qualquer outra.
- **Ramo principal, ainda não enviado**: decide a regra do repositório.
  Por padrão não se reescreve, e a errata vai como acima. Um repositório
  pode abrir uma janela só para a mensagem, com a aprovação do autor; então a
  reescrita mantém todas as árvores, e o sha velho se procura onde já foi
  citado (o rastreador de tarefas, as notas) e se troca.

No rascunho e no ramo ainda não juntado, o agente autor aplica um achado
pela etapa 6 do motor: a correção conferida antes de entrar, a mesma
afirmação procurada nas outras mensagens da série e nos arquivos que o
commit escreve. Uma frase que uma segunda passada acha errada de novo não
se estreita uma terceira vez: sai, ou vira a frase mais fraca que um
comando prova. Uma afirmação de ausência sobre o pai ("só pedia",
"nenhuma skill pedia") se escreve como a busca que a mostra, ou cai. Em
2026-10-26, uma frase assim levou três passadas, cada uma estreitando a
anterior; numa medição no mesmo dia, ela voltou imprecisa tanto de um
remendo conferido quanto de uma reescrita do parágrafo dela a partir da
árvore, e a reescrita custou mais e acrescentou afirmações.

## 7. Passadas e momento

Três momentos num ramo, e o momento 1b para um commit feito direto no
ramo principal, cada um barato porque o artefato é curto:

1. **Antes de todo commit, pelo agente autor, sem subagente.** O agente
   lista as afirmações do rascunho e roda um comando por afirmação,
   guardando a saída, antes do `git commit`: de três a oito comandos. O
   mesmo contexto que escreveu a mensagem a confere, então esta passada
   pega os deslizes (uma contagem, o nome de uma opção) e perde os pontos
   cegos. As seis conferências da autoconferência da skill
   `mensagem-de-commit` (o assunto sozinho, quantificadores, números,
   afirmações de sabotagem, escopo, outros commits) são os comandos que
   mais importam: em 2026-10-26, um levantamento de 43 revisões (41
   ramos) classificou 209 dos 366 achados de mensagem que o subagente
   deste cartucho fez na revisão como esses seis deslizes.
1b. **Antes de um commit feito direto no ramo principal**, que nenhuma
   revisão de ramo vai ler (a prosa de um texto acadêmico, o rastreador
   de tarefas): um subagente só de leitura, sem nada do contexto da
   sessão, sobre o rascunho e a mudança que ele descreve (o brief abaixo,
   com o rascunho no lugar do intervalo). Ele roda depois do momento 1 e
   antes de a mensagem ir ao autor; onde o commit espera a aprovação do
   diff pelo autor, a mensagem vai com o diff, e a aprovação cobre os
   dois. É o contexto limpo que falta ao momento 1, na única hora em que
   uma correção ainda é livre nesse ramo.
2. **Na revisão do ramo, um subagente só de leitura sobre a série** (o
   eixo Fatos da `revisao-rigorosa`, ou avulso num ramo só de
   documentação, que uma revisão de código pularia). Ele extrai e confere
   numa rodada só; acima de ~30 afirmações, o agente principal extrai e
   divide em lotes de 4–8. Esta passada tem o contexto limpo que falta à
   primeira.
3. **De novo depois que o ramo é condensado**, sobre as mensagens finais,
   junto com o eixo História: o rebase reescreveu as mensagens a partir
   da árvore e mudou os shas da série, e uma mensagem reescrita nunca
   passa pelas ferramentas que leem a mensagem no comando `git commit`
   (o hook `commit-msg` do próprio git roda numa reescrita, mas não
   confere fatos).
   Antes dela, o agente autor roda de novo o momento 1 sobre cada
   mensagem reescrita, contra a árvore daquele commit, não a da ponta.
   No mesmo levantamento, 8 das 43 revisões rodaram o subagente de Fatos
   em mais de uma rodada depois da condensação, e os classificadores do
   levantamento puseram 8 dos 117 achados de mensagem que ele fez nas
   rodadas depois da condensação (repetidos deixados de fora) sob a causa
   de uma frase que aponta para o próximo commit da série, afirma um fato
   que um commit posterior tornou falso ou descreve o estado de antes da
   condensação.

Um portão mecânico, onde o repositório tiver um (um hook de pre-commit
ou de antes da ferramenta que confere que todo sha citado resolve, todo
caminho citado existe, todo id de tarefa e número de decisão existe, os
sobrenomes de uma fonte citada por autor e ano batem com a entrada dela
na bibliografia), roda antes do 1 e não custa nada; pega o sha inventado,
o caminho errado e o coautor errado, e não o verbo, a atribuição nem a
contagem.

## 8. Lotes e modelo

Um subagente por série, por padrão, no modelo que a `revisao-rigorosa`
fixa para os eixos dela (o passo 4 dela, "Modelo"), também quando esta
checagem roda sozinha e não como o eixo Fatos; lotes de 4–8 afirmações
acima de ~30 afirmações, todos lançados numa mensagem só. A passada do
agente autor (momento 1) não usa subagente.

O Codex roda ao lado do subagente nos momentos 1b, 2 e 3, com o brief
abaixo depois do preâmbulo do motor (SKILL.md da `checagem-de-fatos`,
"O segundo provedor:
Codex"), e não no momento 1. Quando o verificador extrai por conta
própria, as duas listas se casam por `sha:line` e pela citação da
afirmação. Como eixo Fatos da `revisao-rigorosa` a regra é a mesma: quem
lança o subagente de Fatos lança esta chamada do Codex ao lado dele, à
parte de qualquer eixo Codex da própria revisão.

O subagente trabalha em lotes, como o brief diz: cada turno relê o
contexto inteiro dele, então um turno poupado é uma releitura dele
poupada. Medido em 2026-10-26 sobre três ramos juntados de um
repositório, o mesmo brief com o parágrafo dos lotes levou 24, 34 e 24
turnos contra 29, 49 e 47, e 13%, 24% e 43% menos tokens, ponderados pelo
preço (leituras de cache a um décimo, escritas de cache a 1,25, saída a
5); as leituras de cache foram 78%, 92% e 80% dessa economia. Em dois
ramos, cada rodada achou algo que a outra perdeu; no terceiro, a rodada
sem lotes achou uma imprecisão a mais. Uma rodada só nunca prova uma
série limpa.

## 9. Onde fica o relatório e em que língua

Na conversa, por commit: sha, número de afirmações, vereditos e cada
correção como a frase exata a trocar, só fatos. Numa revisão de ramo, sob
o título Fatos do relatório da revisão. A língua é a dos commits do
repositório.

## O brief do subagente

~~~markdown
Você é o verificador hostil das mensagens de commit de {{RANGE}} em
{{REPO}}. O autor contratou a sua hostilidade: ache todo fato destas
mensagens que o repositório não sustenta. Presuma toda afirmação errada
até a árvore mostrar o contrário. Julgue fato e lógica, não estilo.

Leia cada mensagem com `git log --format='%H%n%B' {{RANGE}}`. (Para um
rascunho, momento 1b: a mensagem é o arquivo {{DRAFT}}, a mudança é
`git diff --cached` ou `git diff HEAD -- <os caminhos nomeados>`, e a
âncora é `draft:line`.) De cada
mensagem, extraia toda afirmação conferível (um sha citado e o que ele
fez; um caminho e o que ele diz; uma regra citada ou parafraseada, com o
verbo; uma contagem; um nome, versão, opção ou comando; uma data ou um
"desde"; "só comentário", "nenhuma mudança funcional", "o teste passa";
uma fonte citada por autor e ano; a linha de assunto lida sozinha, como
o `git log --oneline` a mostra; o problema dito como fato sobre o pai; a
alternativa recusada; a frase de escopo).

Confira cada uma na primária: `git show <sha>` e `git show <sha>:<path>`
para o próprio commit e para qualquer commit que ele cite (o diff do
commit citado, nunca a mensagem; `git log -S'<text>' -- <path>` acha que
commit introduziu uma linha); `git show <sha>^:<path>` para o problema no
pai; o arquivo de instruções na árvore do commit para uma regra citada,
na frase exata; o registro da tarefa no rastreador de tarefas ou o
ticket para uma tarefa; o
arquivo para um registro de decisão; o arquivo de teste ou a saída do
comando para uma contagem; a entrada da bibliografia (cada sobrenome de
`author`, em ordem, e a data) e o arquivo de trechos para uma fonte
citada por autor e ano. Um achado de revisão que a mensagem menciona não
é evidência; o fato tem de aparecer na árvore. Também não é o corpo de
uma tarefa nem o pedido que abriu a sessão: um nome ou uma página que
eles afirmam é cópia, conferida na fonte dela. Você lê; não edita, não
faz commit, não faz rebase nem escreve nada.

Trabalhe em lotes, porque cada turno relê o seu contexto inteiro.
Primeiro leia todas as mensagens e escreva, para você, a lista de
afirmações e o comando que confere cada uma. Depois rode os comandos de
uma mensagem (ou de várias) numa chamada só de Bash, separando as saídas
com marcadores `echo "== A01"`, ou faça várias chamadas de ferramenta em
paralelo no mesmo turno. Abra mais um comando só para uma afirmação que a
saída do lote não decidiu. Mire em um a três turnos de ferramenta por
mensagem.

Nunca mande a um serviço externo o e-mail, o nome ou outro dado pessoal
do autor, mesmo que os ache no ambiente.

Vereditos: falsa, imprecisa, enganosa, sem fonte, correta, fora do
escopo.

Saída: um bloco ```json com uma lista, um objeto por afirmação:
{"sha", "line", "verdict", "claim_quote", "finding", "evidence":
[{"command", "quote" (saída ou texto do arquivo, literal)}],
"supports_problem" (true se a descrição do problema cai sem ela),
"minimal_correction" (só o fato, na língua da mensagem; "DISCUTIR COM O
AUTOR" quando a própria descrição do problema é falsa)}. Um número em
minimal_correction leva a sua base (o que foi contado, de onde); uma
afirmação de ausência ou um quantificador ("só", "nenhum", "todo") se
corrige para a frase mais fraca que a evidência cita, não para uma
ausência mais estreita.
~~~

## Anti-exemplos resolvidos

- **Verbo inflado.** Uma mensagem diz que uma regra "exige" que a versão
  em Lit mantenha todos os métodos da versão em Web Component. A regra,
  na árvore do commit, diz que as duas devem "diferir o mínimo além da
  ligação do estado à tela". Veredito: imprecisa; correção: "para manter
  o par tão próximo quanto o item pede". O método pode até ficar; o
  motivo dado para ele não era o da regra.
- **Atribuição ao commit errado.** Uma mensagem diz "como aconteceu com o
  Quadro até 0abe102". `git show 0abe102` mostra que esse commit só
  reescreveu o item (tirou um qualificativo); `git log -S'Quadro' --
  AGENTS.md` lista 27aca29 como o último commit que mudou quantas vezes
  "Quadro" aparece no arquivo, e o diff dele é o que acrescenta o Quadro
  ao item. Veredito: falsa; correção: o sha. A regra do projeto já
  proibia reescrever então, e a errata foi na próxima mensagem que tocou
  o item.
- **Nome como na tarefa, não como na bibliografia.** Uma mensagem de um
  repositório de texto acadêmico citou "Britton e Jarvis (2001, p. 267)";
  a entrada da bibliografia diz Britton e Kutar. O texto que o commit
  mudou citava a fonte só pela chave, e "Britton e Jarvis" já estava no
  corpo da tarefa em que o commit trabalhou, no pai do commit. A linha
  "Fontes conferidas" do commit, que lista as fontes declaradas
  conferidas, nomeia só outra. Veredito: falsa; correção: o sobrenome. A
  mesma série tinha o assunto "Tira da lista as oito dimensões deixadas
  de fora" para um commit em que as oito ficavam na lista: enganoso, lido
  sozinho. Os dois chegaram ao ramo principal, que é para o que serve o
  momento 1b.
- **Contagem.** "os quatro" quando eram cinco (a pasta de especificações
  lista cinco: `ls implementacoes/openspec/specs | wc -l`). Pego pelo
  agente autor antes do commit e consertado com um amend; é para isso que
  serve o momento 1.
