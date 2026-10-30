---
name: mensagem-de-commit
description: >-
  Escreve mensagens de commit que explicam por que a mudança existe, no
  estilo de um patch do kernel Linux: o problema primeiro, a correção
  escolhida e a alternativa recusada, o que fica fora do escopo e como se
  testou. Use ao rascunhar, escrever, reescrever ou revisar uma mensagem
  de commit, commitar, dividir o trabalho em commits, reescrever depois de
  um squash ou rebase, ou quando o usuário disser "commita isso",
  "/commit" ou perguntar por que uma mensagem está fraca. Adapta a forma
  (prefixo, idioma, quebra, trailers) às convenções do repositório; rege
  o conteúdo. Também em inglês: "commit-message", "commit this", "write
  the commit".
---

# Mensagem de commit

A mensagem é a única parte de uma mudança que sobrevive no `git log`, no
`git blame` e no resultado do bisect que alguém lê anos depois, sem acesso
ao pull request, ao ticket ou à conversa que a produziram. O diff diz o que
mudou. A mensagem diz por quê, e por que desse jeito. Escreva para esse
leitor.

## A forma segue o repositório

Esta skill rege o que a mensagem diz. O repositório rege a cara que ela
tem. Antes de rascunhar, aprenda a forma local:

```bash
git log -20 --format='%s%n%n%b%n----'
```

Leia a convenção do assunto (Conventional Commits `type(scope):`, um
prefixo `area:` ou prosa simples), o idioma, a largura da quebra do corpo e
os trailers em uso. Leia o guia de contribuição, o arquivo de instruções
para agentes (`AGENTS.md`, `CLAUDE.md`) ou o documento de fluxo do git que
o repositório mantiver.

A forma se decide nesta ordem, e vale a primeira que se aplicar:

1. **Uma regra explícita** do usuário ou dos documentos do repositório (um
   tamanho de assunto, um escopo obrigatório, uma largura de quebra, um
   trailer).
2. **Precedente na história.** Quando a maioria dos commits recentes
   compartilha uma forma (assuntos abaixo de um tamanho menor, um prefixo
   `type(scope):`, outra quebra), siga-a. Um ou dois commits fora da linha
   não são precedente.
3. **Os valores padrão abaixo**, quando o repositório não diz nada e a
   história dele não mostra padrão consistente.

### Valores padrão

- **Assunto: uns 60 caracteres**, nunca além do que um log de uma linha
  mostra inteiro. Longo o bastante para nomear a mudança, curto o bastante
  para se ler de relance numa lista de centenas.
- **Corpo: quebrado em 72 colunas.** O git recua o corpo no `git log`, e as
  ferramentas que trabalham por e-mail o citam; 72 deixa espaço para as
  duas coisas num terminal de 80 colunas.
- **Prefixo do assunto: nenhum imposto.** Siga a história; um repositório
  sem padrão leva um assunto simples no imperativo.

## Antes de escrever

1. **Leia a própria mudança.** Prefira o retrato do que está no stage
   (`git diff --staged`); na falta dele, `git diff`. Ao reescrever a
   mensagem de um commit que já existe, leia-o contra o pai com
   `git show <commit>`.
2. **Diga a mudança em duas frases:** o que estava errado, e por que esta
   correção. Se não conseguir, o commit talvez tenha mais de uma mudança
   lógica. Divida-o quando as partes se separam limpas, cada commit sendo o
   pai mais linhas do diff final e passando nos próprios testes: uma
   correção de bug, uma limpeza, uma mudança de API e um novo chamador
   dessa API são quatro commits; uma mudança espalhada por muitos arquivos
   é um. Partes que dividem uma mesma reestruturação, em que um commit
   intermediário precisaria de código que não está nem no pai nem na
   mudança terminada, ficam num commit só, e o corpo diz por que vão
   juntas.
3. **Não deixe o movimento esconder a modificação.** Uma renomeação, um
   deslocamento ou uma reformatação vai num commit próprio, antes da
   mudança de lógica, quando esconderia a mudança, para que ninguém tenha
   de achar a correção de uma linha dentro de uma reformatação de
   trezentas: quando, mesmo com as opções do diff que olham através dele
   (`-w`, `--color-moved`, `--word-diff`), o leitor tem de ler as linhas
   mecânicas para achar a mudança. Uma reformatação ampla feita por uma
   ferramenta vai sempre sozinha, para que um arquivo de blame-ignore a
   pule sem pular lógica junto. Uma renomeação local, uma quebra de linha
   que a edição força e a renomeação que segue uma mudança no contrato da
   mesma função ficam com a mudança: o nome antigo descreve o contrato
   antigo. Siga a regra do repositório quando ela pedir cada movimento num
   commit próprio.
4. **Depois de um squash ou rebase, escreva a partir da árvore, não das
   mensagens antigas.** Uma fileira de commits pequenos é um diário.
   Guarde uma frase antiga só quando ela ainda bate com o diff.
5. **A correção de um commit anterior do mesmo ramo ainda não juntado não
   é uma mudança nova.** Quando o ramo não chegou ao ramo principal e
   ninguém mais constrói em cima dele, faça o commit da correção com
   `git commit --fixup=<sha>` (ou faça amend do último commit), para que o
   ramo possa se condensar com `git rebase -i --autosquash` antes do merge.
   Uma mensagem que só diz "fix the previous commit" ou "address review"
   nunca chega ao ramo principal. Siga a regra do repositório onde ela
   disser outra coisa.

## Esqueleto

```
<assunto: resumo no imperativo, na convenção de prefixo do repositório>

O que está errado na árvore hoje, dito como fato sobre o código e o
comportamento dele: o sintoma, o caso que falha, o número errado.

Por que esta correção, e por que não a alternativa óbvia. O que se
considerou e se recusou, numa frase.

O que deliberadamente não se faz aqui, se um leitor esperaria isso.

Como se testou: um comando, um caso, um número.
```

Nem todo commit precisa de todas as partes. Uma mudança que se explica
sozinha pode precisar só do assunto. Uma correção de bug, uma mudança de
comportamento, uma mudança que quebra compatibilidade, uma correção de
segurança, uma migração de dados e um revert sempre levam corpo.

## Regras do assunto

- **Modo imperativo.** O assunto completa a frase "this commit will ...":
  "add", "drop", "fix", e não "added" nem "adds". Num repositório escrito
  em outra língua, use a convenção dessa língua para o assunto do commit.
- **Diga o que muda no comportamento, não que arquivo mudou.** Nomes de
  arquivo, nomes de classe e detalhes de implementação ficam no diff.
- **Tamanho conforme os [valores padrão](#valores-padrão)**, salvo quando
  o repositório define o seu, sem ponto final.
- **Comece com um verbo.** Um sintagma nominal ("schema alignment") soa
  como manchete e esconde a ação.

## Regras do corpo

- **O problema primeiro.** O leitor tem de poder discordar do diagnóstico
  antes de ver o remédio. A mensagem que abre com a solução pula a parte
  que o revisor está ali para conferir.
- **Presente sobre a árvore, não passado sobre você.** "The loader keeps
  duplicate rows", e não "I noticed duplicates" nem "Updated the loader".
  O processo do autor não faz parte da história da árvore.
- **Nomeie a alternativa que recusou.** Uma frase impede o revisor de
  sugeri-la e mostra que a escolha foi feita, e não herdada por omissão.
- **Diga o que fica fora do escopo** quando um leitor esperaria isso.
  Poupa uma ida e volta de revisão.
- **Diga como testou.** "Ran the tests" é fraco. Nomear o teste que falha
  no commit pai e passa neste é uma afirmação que o revisor pode conferir.
- **Commit preparatório diz que é.** O commit que move ou renomeia sem
  mudar comportamento termina o corpo com "No functional change." A frase
  é uma promessa que o revisor vai conferir.
- **Nunca descreva o diff.** "Added function X, modified Y, updated tests"
  é para isso que existe o `git show --stat`. Se o corpo só lista
  mudanças, apague-o e recomece do problema.
- **Nada de verbo vazio.** Nunca escreva "improve", "enhance", "clean up"
  ou "refactor for maintainability" sem dizer o que era difícil antes.
- **Prosa, não tópicos.** Escreva parágrafos curtos que carreguem o
  raciocínio. Guarde a lista para o que é lista de verdade, como os passos
  em ordem de uma migração.
- **A mensagem se sustenta sozinha.** A referência a um ticket é bem-vinda
  como trailer, nunca como a mensagem inteira: o ticket vai sumir ou ficar
  ilegível muito antes do código.
- **A prosa é sobre o código, não sobre o autor.** O assunto e os
  parágrafos do corpo nunca narram quem ou o que escreveu a mudança ("I,
  an AI assistant, ..."). A atribuição tem um lugar fixo, depois do corpo;
  ver [Atribuição de IA por padrão](#atribuição-de-ia-por-padrão).

## Todo fato tem fonte

O esqueleto pede um sintoma, um caso que falha, um número. Cada um vem do
usuário, do ticket ou de um comando cuja saída você tem em mãos. O que
você não tem, pergunte uma vez, ou escreva a frase mais fraca que é
verdadeira sem ele ("the new test shows `load_prices()` returns both
rows"). Um número inventado é pior que nenhum: o primeiro "qual
relatório?" acaba com a credibilidade do autor diante desse revisor.

Vale o mesmo para todo fato que a mensagem afirma sobre a árvore: um sha
citado e o que ele fez, um caminho e o que ele diz, uma regra citada de um
arquivo de instruções e o verbo dela, uma contagem, uma data, um "comment
only". Antes de mostrar o rascunho, confira cada um com o comando que o
prova (`git show <sha>`, `git show :<path>`, `git show HEAD:<path>`, a
execução dos testes) e tenha a saída em mãos. O cartucho de checagem de
fatos desta skill (`cartuchos-de-fatos/mensagem-de-commit.md`, que a
skill `checagem-de-fatos` carrega) lista as categorias de afirmação, os
comandos e o pedido ao subagente; esta
passada é o primeiro momento dele, feito só pelo agente que escreve,
enquanto o amend ainda sai de graça. Uma mensagem no ramo principal nunca
se reescreve, e por isso um fato errado achado depois sobrevive como
errata numa mensagem posterior. O sha do mesmo ramo ainda não juntado é
um alvo móvel, que o rebase de condensação reescreve: cite o assunto dele
entre aspas ao lado, como faz o trailer `Fixes:`, e confira de novo depois
do rebase. Toda mensagem que o rebase de condensação reescreve passa de
novo pela autoconferência, contra a árvore do próprio commit
(`git show <sha>:<path>`), e não contra a da ponta: é na reescrita que
entra a frase sobre um commit posterior.

Um achado da checagem de Fatos sobre a sua própria mensagem se aplica pela
etapa 6 da skill `checagem-de-fatos`: confira a correção antes de ela
entrar, releia as palavras vizinhas e as outras mensagens atrás do mesmo
deslize, e corte ou enfraqueça, em vez de estreitar de novo, a frase que
volta de uma segunda passada.

## Trailers

Depois do corpo, um por linha, cada um uma afirmação que alguém pode
conferir. Use só os trailers que o repositório já usa ou que o usuário
pede, mais a atribuição de IA abaixo.

- `Fixes: <12-char sha> ("<subject of that commit>")` quando este commit
  corrige um defeito que um commit anterior específico introduziu. O
  assunto entre aspas mantém a referência legível depois de um rebase.
- `Reported-by:`, `Tested-by:`, `Reviewed-by:`, `Acked-by:` só com a
  concordância da pessoa, e só pelo que ela fez.
- `Refs:`, `Link:`, `Closes #N` para o ticket ou a discussão.
- `BREAKING CHANGE:` quando a convenção do repositório o usa.

## Atribuição de IA por padrão

O commit que um agente de IA escreveu ou ajudou a escrever diz isso. O
leitor do `git log` e do `git blame` tem direito de saber que a mudança
passou por um agente, e por qual.

1. **Use a atribuição que o seu harness fornece, ao pé da letra.** Os
   harnesses de agente costumam entregar ao agente as linhas exatas com
   que terminar um commit (o Claude Code, por exemplo, fornece uma linha
   como `Co-Authored-By: Claude <model> <noreply@anthropic.com>`).
   Copie-as como vieram: o trailer vai no bloco de trailers, e uma linha
   de banner que o harness fornece para commits vai numa linha própria
   logo acima do bloco de trailers.
2. **Sem nada fornecido, assine você mesmo** com um trailer na forma
   `Co-Authored-By: <agent or model name> <noreply address>`. Nomeie só o
   que você sabe de si pelo seu próprio contexto: o nome do modelo ou do
   produto que lhe deram, e o endereço no-reply do fornecedor. Nunca chute
   uma versão de modelo.
3. **Uma regra explícita vence.** Quando o usuário ou o repositório (um
   arquivo de instruções ou um guia de contribuição) proíbe a atribuição
   de IA, ou dá outra forma, como `Assisted-by:`, siga essa regra.
   Precedente sozinho não é essa regra: uma história sem trailers de IA
   em geral quer dizer que os commits anteriores foram escritos à mão.

A atribuição nunca vai no assunto, e nunca toma o lugar do corpo: a
mensagem ainda tem de explicar a mudança sozinha.

## Fluxo

1. Rascunhe a mensagem inteira (assunto, corpo, trailers) e mostre-a ao
   usuário. **Não rode `git commit` antes de o usuário confirmar
   explicitamente.**
2. Ponha no stage só o que pertence a este commit. Nunca ponha segredos
   no stage (arquivos `.env`, credenciais, chaves privadas).
3. Faça o commit com um heredoc, para que a mensagem de várias linhas
   chegue intacta:

   ```bash
   git commit -F - <<'EOF'
   <subject>

   <body>

   <trailers>
   EOF
   ```

4. Se um hook falhar, conserte a causa e faça o commit de novo. Nunca pule
   hooks (`--no-verify`) nem mude a configuração do git. Nunca faça amend,
   rebase nem force push de história que já está no ramo principal ou foi
   enviada para outros, a menos que o usuário peça; condensar os fixups
   num ramo ainda não juntado (Antes de escrever, passo 5) não é isso.

## Autoconferência antes de mostrar o rascunho

- O primeiro parágrafo nomeia o que estava errado, como fato sobre o
  código?
- Um revisor acharia a alternativa recusada, o limite do escopo e o teste
  só pela mensagem?
- Alguma frase repete o diff? Apague-a.
- Todo número, data e nome tem uma fonte que você pode citar? Você rodou o
  comando que prova cada sha, caminho, regra e contagem da mensagem, e a
  saída dele diz o que a mensagem diz
  ([Todo fato tem fonte](#todo-fato-tem-fonte))?
- Você fez as seis conferências abaixo? Em 2026-10-26, um levantamento de
  43 revisões (41 ramos) de um repositório classificou como estes seis
  deslizes 209 dos 366 achados que o eixo Fatos fez sobre as mensagens, e
  71 dos 117 que ele fez nas rodadas depois da condensação (sem as
  repetições, nas duas contagens):
  1. **O assunto, sozinho.** `git log --oneline <base>..HEAD` (ou a
     primeira linha do rascunho): ele diz mais do que o commit faz, ou
     outra coisa?
  2. **Quantificadores.** Procure no rascunho "any", "every", "all",
     "always", "never", "none", "only", "each" (e as palavras da língua do
     repositório para eles). Cada um ganha o comando que o prova, ou um
     quantificador menor.
  3. **Números.** Cada contagem se refaz com o comando que a produziu, na
     árvore que vai ao commit; a contagem de testes cita a linha de resumo
     da execução.
  4. **Afirmações de sabotagem.** A frase que diz que um teste falha numa
     cópia quebrada, numa variante ou num caso: rode o teste nessa cópia.
  5. **Escopo.** "Only", "no functional change", "does not touch":
     `git diff --staged --stat` (ou `git show --stat <sha>`) contra a
     frase.
  6. **Outros commits.** Procure "next", "previous", "later", "not yet" (e
     as palavras da língua do repositório): a frase que só é verdadeira
     com outro commit da série sai, ou cita o assunto desse commit.
- A mensagem termina com a atribuição de IA (as linhas do harness ao pé da
  letra, ou o seu próprio `Co-Authored-By:`), salvo quando uma regra
  explícita do usuário ou do repositório a proíbe ou dá outra forma?
- O tamanho do assunto, o prefixo e a quebra do corpo seguem a regra ou o
  precedente do repositório, e os valores padrão (uns 60 caracteres, 72
  colunas) onde ele não tem nenhum dos dois?

Exemplos comentados, ruins e bons:
[references/exemplos.md](references/exemplos.md).
