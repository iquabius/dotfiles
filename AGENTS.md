# Instruções para agentes: dotfiles

As regras de trabalho neste repositório: o ciclo de ramo, revisão e
merge, os portões que o guardam, os testes e os commits. O que é cada
pasta e como se instala está no [readme.md](readme.md).

Configuração pessoal em pacotes GNU Stow, em português. O ciclo é
guardado pelo `git-revisao`, pelo `git-assunto-merge` e pelo
`claude-revisao-guarda`, do pacote `bin` (a lista dos comandos está no
[`pacotes/bin/readme.md`](pacotes/bin/readme.md)), com os hooks do git
ligados pelo pacote `git`.

## Ciclo: ramo, revisão, merge

Todo trabalho, de pessoa ou de agente, chega ao `main` assim (decisão de
2026-10-07, revista em 2026-10-14). O que está no `main` ou foi enviado é
registro e não se reescreve; o ramo ainda não mesclado é rascunho, e a
história dele se condensa antes do merge (passo 5).

1. **Worktree em ramo próprio.** O checkout principal (`~/.dotfiles`)
   fica no `main`: outras sessões e o editor commitam ali, e um ramo nele
   desvia os commits delas (decisão do autor de 2026-11-12). Antes do
   primeiro commit, confira `pwd` e `git worktree list` e, do checkout
   principal, `git worktree add -b <tarefa> .claude/worktrees/<tarefa>
   main`; o trabalho segue na worktree. A mudança ainda não commitada no
   checkout principal não vai junto: a da tarefa passa por `git diff
   HEAD -- <arquivos> | git -C .claude/worktrees/<tarefa> apply`, o
   arquivo novo ainda fora do índice, que o `git diff` não mostra, se
   copia, e sai do checkout principal só o arquivo cuja mudança é toda
   do agente (`git restore --source=HEAD --staged --worktree --
   <arquivos>`, e `rm` no arquivo novo); o que tem também mudança de
   outra sessão ou do autor fica, e o agente pergunta ao autor. Uma
   tarefa por ramo, com um nome que a diga, de horas a dois dias. O
   `claude-revisao-guarda` recusa ao Claude Code, e não ao Codex, as
   formas diretas de tirar do `main` o HEAD de um checkout principal
   (seção *Portões*).
2. **Primeira versão commitada** assim que funciona, rodada pelo caminho
   da worktree (*Onde a mudança vale*): o Emacs abre sem erro, o fish
   carrega, o script roda e o `make check` passa (ver *Testes*).
3. **Revisão do ramo inteiro.** Quando o ramo muda código (um caminho
   que casa com uma linha do [`.config/revisao`](.config/revisao), como
   os hooks, os scripts e as suítes, o `Makefile`, o Emacs Lisp, o fish,
   o `pacotes/ssh/.ssh/rc` e a configuração que liga os portões), rode a
   skill `revisao-rigorosa` sobre `$(git merge-base main HEAD)...HEAD`.
   Ramo só de texto ou de configuração simples (readme, `settings.json`
   dos editores, `tmux.conf`, `latexmkrc`) dispensa a revisão, mas não o
   ramo.
4. **Cada achado bloqueante vira um conserto** no ramo: `git commit
   --fixup=<commit que ele corrige>`, ou commit novo quando ele não
   corrige um commit só. Revise de novo até o veredito **Pronto para o
   merge**. O achado não bloqueante vai ao autor, que decide o destino
   dele (passo 6 da `revisao-rigorosa`).
5. **Condense o ramo** antes de marcar (passo 7 da `revisao-rigorosa`): cada
   conserto entra no commit que ele corrige, e a série fica com uma
   mudança lógica por commit, com as mensagens escritas a partir da
   árvore (skill `mensagem-de-commit`), sem as rodadas da revisão:

   ```sh
   revisada=$(git rev-parse HEAD)
   GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash "$(git merge-base main HEAD)"
   git diff "$revisada" HEAD   # tem de sair vazio
   ```

   A série refeita à mão (juntar, dividir, reescrever mensagens) passa
   pelo mesmo `git diff` vazio. Com a árvore igual à revisada, só os eixos
   História e Fatos da `revisao-rigorosa` rodam de novo, sobre a série nova;
   com outra árvore, a revisão do ramo inteiro.
6. **Marque a ponta**: `git revisao pronto`, da ponta, na worktree e sem
   código mudado fora do commit. Ele roda antes o teste da linha `teste:` do
   `.config/revisao` (`scripts/testes-da-revisao`, que escolhe as suítes
   pelo diff do ramo) e não marca se o teste falha. Achado bloqueante
   que o autor decide deixar de pé: `git revisao excecao -m "<motivo do
   autor>"`. O agente não decide isso sozinho.
7. **Merge no main**, no checkout principal, sem rebase nem squash na
   hora do merge; o `post-merge` roda ali o `stow -R bin` (*Onde a
   mudança vale*):

   ```sh
   # no checkout principal, no main
   git merge --ff-only <tarefa> ||
       git merge --no-ff -m "Mescla o ramo <tarefa>: <o que o ramo traz>" <tarefa>
   git revisao pendente   # tem de dizer "nada pendente"
   git worktree remove .claude/worktrees/<tarefa>
   git branch -d <tarefa>
   ```

8. **O push é do autor.** O agente não faz push.

Nunca, no que já está no `main` ou foi enviado: `git commit --amend`,
rebase ou outra reescrita da história, `git rebase main`, merge squash.
Nunca, em lugar nenhum: `--no-verify`. No ramo ainda não mesclado,
reescrever é o passo 5, e nenhum commit `fixup!` chega ao `main`.

## Portões

- **pre-push** (`git-revisao`, hook global do pacote `git`): recusa
  commit que mexe em caminho de `.config/revisao` e chega ao `main` sem a
  marca de `git revisao pronto` (ou `excecao`) que o cubra. A marca é uma
  nota local em `refs/notes/revisao` e não vai para o GitHub. O
  `pacotes/git/.gitconfig` que liga este hook e o `pacotes/claude/` que
  registra o guarda são caminhos revisados, mas o stow os liga à árvore
  de trabalho do `~/.dotfiles`: a mudança vale assim que chega a esse
  checkout, pela edição ou pelo merge. O ramo que apaga o
  `[hook "revisao-push"]` faz então o push sem o pre-push, e só a
  revisão do passo 3 o segura; o que tira o guarda do `settings.json`
  (na máquina sem a camada privada) o desliga antes do push, que o
  pre-push ainda confere.
- **pre-commit** (`git-revisao`): recusa commit de agente no `main` que
  mexa no código. O git não o chama em `cherry-pick`, `revert` nem `am`,
  salvo no `cherry-pick --continue` e no `revert --continue` depois de um
  conflito: o resto do que eles levarem ao `main` só o pre-push pega. O
  `.githooks/pre-commit` deste repositório continua recusando caminho
  absoluto de home nas linhas novas.
- **commit-msg** (`git-assunto-merge`, hook global do pacote `git`):
  recusa no commit de merge o assunto "Merge branch '<ramo>'", que o git
  escreve quando o merge vem sem `-m`, e o "Mescla o ramo <ramo>:" (ou o
  "Junta o ramo <ramo>:" antigo) que não diz o que o ramo traz.
- **Hook do Claude** (`claude-revisao-guarda`, registrado no
  `~/.claude/settings.json` pelo pacote `claude` ou pelo da camada
  privada): recusa as formas diretas de pular os hooks (`git
  commit --no-verify` ou `-n`, `git push`, `merge` ou `pull` com
  `--no-verify`, também num alias gravado, mexer em `core.hooksPath`,
  `hook.*` ou `include.*`, trocar a configuração global pelo
  ambiente num commit, merge, pull ou push, tirar `CLAUDECODE` do
  ambiente, pelo qual o pre-commit reconhece o agente), escrever as notas da
  revisão à mão ou apontar a elas o `core.notesRef` ou o
  `notes.rewriteRef`, o merge pelo GitHub, o `gh` com a palavra `auth`,
  menos as formas do `gh auth status` sem o token e da ajuda que o
  `pacotes/bin/readme.md` lista, o `oauth_token` do `gh config` e criar
  alias do `gh`, também pelo `gh-escrita` da camada privada, e tirar do
  ramo principal o HEAD de um checkout principal (`git switch` e `git
  checkout` para um ramo novo, outro ramo ou um commit, `git rebase
  <base> <ramo>`, `git stash branch`, `gh pr checkout`, também pelo
  `-C`, pelo `cd` ou pelo `env -C` de outro repositório); pergunta ao
  autor antes de `git revisao excecao`. Confere o Bash e o terminal do
  app (`mcp__terminal__run_in_terminal`). O portão que segura é o
  pre-push do push do autor; no `gh`, que não passa por ele, o que
  segura é o escopo do token que o autor deu ao `gh` e o autor, que
  aprova no navegador o login e o refresh, e no `gh-escrita` o diálogo
  da chave do App.
- **Outros hooks da camada privada**: têm regras próprias, além da
  revisão. Siga o que a mensagem de cada um disser; nunca os pule.

## Onde a mudança vale

Os pacotes stow apontam para a árvore de trabalho do `~/.dotfiles`, que
fica no `main`: o que um ramo muda na worktree só chega aos links do
`$HOME` depois do merge. Para ver a mudança funcionar antes dele (o
Emacs que abre, o fish que carrega), rode-a pelo caminho da worktree.
Arquivo novo que precisa de um link próprio (fora de uma pasta que o
stow já ligou inteira) só chega ao `$HOME` depois do `stow` do pacote,
rodado no checkout principal depois do merge. Script
novo em `pacotes/bin/.local/bin/` chega ao `PATH` pelo `stow -R bin`,
que o `post-merge` roda, aqui e na camada privada, depois de todo merge
sem conflito no `~/.dotfiles` ou no `~/.dotfiles-private` que muda o
pacote `bin`, e não numa worktree; sem `~/.local/bin`, ele só avisa e
pula o stow.

## Testes

```sh
distrobox-host-exec sh -c 'cd ~/.dotfiles && make check'
```

Numa worktree, o `cd` vai a ela. Roda no host: ShellCheck e `shfmt -i
4` nos `SCRIPTS` do `Makefile` (script de shell novo entra nessa lista)
e o bats em `tests/` e em `pacotes/bin/.local/bin/`, onde as suítes
moram ao lado dos scripts. Caso de borda novo vira teste antes da
correção, e todo teste novo é conferido contra uma cópia sabotada do
arquivo testado, que ele tem de reprovar: cada suíte diz a variável
que o troca (`SKILLS_SYNC_SCRIPT`,
`GIT_REVISAO_SCRIPT`...). Durante o trabalho, `GIT_REVISAO_BASE=$(git
merge-base main HEAD) scripts/testes-da-revisao` escolhe os testes pelo
que o ramo mudou (o lint, as suítes desse código, e o `make check`
inteiro quando muda o que todas usam, um arquivo de código da raiz, como
o `.stowrc`, ou um código sem suíte), os mesmos que o `git revisao
pronto` vai rodar.

## Commits

Em português, no imperativo, sem prefixo, o problema antes da solução e
a alternativa recusada; o commit de correção diz o que corrige. Nada de
caminho absoluto de home no que se escreve: `$HOME` ou `~`.
