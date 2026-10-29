# Instruções para agentes: dotfiles

Configuração pessoal em pacotes GNU Stow, em português: cada diretório da
raiz espelha o `$HOME` (`readme.md`). O `skills-sync`, que liga as skills
de agente, e os perfis dele estão aqui, no pacote `bin` e em `profiles/`.
A identidade do git, o `git-revisao`, que guarda o processo abaixo, e as
skills de agente vêm da camada privada, instalada à parte.

## Ciclo: ramo, revisão, merge

Todo trabalho, de pessoa ou de agente, chega ao `main` assim (decisão de
2026-10-07, revista em 2026-10-14). O que está no `main` ou foi enviado é
registro e não se reescreve; o ramo ainda não juntado é rascunho, e a
história dele se condensa antes do merge (passo 5).

1. **Ramo no lugar.** Antes do primeiro commit, `git switch -c <tarefa>`
   no checkout em que se trabalha; as mudanças ainda não commitadas vão
   junto, e o que não é da tarefa fica fora do índice. Uma tarefa por
   ramo, com um nome que a diga, de horas a dois dias.
2. **Primeira versão commitada** assim que funciona: o Emacs abre sem
   erro, o fish carrega num terminal novo, o script roda e o `make
   check` passa (ver *Testes*).
3. **Revisão do ramo inteiro.** Quando o ramo muda código (os caminhos de
   `.config/revisao`: hooks, Emacs Lisp, fish, scripts de shell, o
   `Makefile`, o `bin/` e as suítes de `tests/`), rode a
   skill `linus-review` sobre `$(git merge-base main HEAD)...HEAD`. Ramo
   só de texto ou de configuração simples (readme, `settings.json` dos
   editores, `.gitconfig`, `tmux.conf`, `latexmkrc`) dispensa a revisão,
   mas não o ramo.
4. **Cada achado vira um conserto** no ramo: `git commit --fixup=<commit
   que ele corrige>`, ou commit novo quando ele não corrige um commit só.
   Revise de novo até o veredito **Ready to merge**.
5. **Condense o ramo** antes de marcar (passo 7 da `linus-review`): cada
   conserto entra no commit que ele corrige, e a série fica com uma
   mudança lógica por commit, com as mensagens escritas a partir da
   árvore (skill `commit-message`), sem as rodadas da revisão:

   ```sh
   revisada=$(git rev-parse HEAD)
   GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash \
       --committer-date-is-author-date "$(git merge-base main HEAD)"
   git diff "$revisada" HEAD   # tem de sair vazio
   ```

   A série refeita à mão (juntar, dividir, reescrever mensagens) passa
   pelo mesmo `git diff` vazio. Com a árvore igual à revisada, só o eixo
   History da `linus-review` roda de novo, sobre a série nova; com outra
   árvore, a revisão do ramo inteiro.
6. **Marque a ponta**: `git revisao pronto`. Achado que o autor decide
   deixar de pé: `git revisao excecao -m "<motivo do autor>"`. O agente
   não decide isso sozinho.
7. **Merge no main**, sem rebase nem squash na hora do merge:

   ```sh
   git switch main
   git merge --ff-only <tarefa> || git merge --no-ff <tarefa>
   git revisao pendente   # tem de dizer "nada pendente"
   git branch -d <tarefa>
   ```

8. **O push é do autor.** O agente não faz push.

Nunca, no que já está no `main` ou foi enviado: `git commit --amend`,
rebase ou outra reescrita da história, `git rebase main`, merge squash.
Nunca, em lugar nenhum: `--no-verify`. No ramo ainda não juntado,
reescrever é o passo 5, e nenhum commit `fixup!` chega ao `main`.

## Portões

- **pre-push** (`git-revisao`, hook global da camada privada): recusa
  commit que mexe em caminho de `.config/revisao` e chega ao `main` sem a
  marca de `git revisao pronto` (ou `excecao`) que o cubra. A marca é uma
  nota local em `refs/notes/revisao` e não vai para o GitHub.
- **pre-commit** (`git-revisao`): recusa commit de agente no `main` que
  mexa no código. O git não o chama em `cherry-pick`, `revert` nem `am`:
  o que eles levarem ao `main` só o pre-push pega. O `.githooks/pre-commit`
  deste repositório continua recusando caminho absoluto de home nas linhas
  novas.
- **Hook do Claude**: recusa as formas diretas de pular os hooks (`git
  commit --no-verify` ou `-n`, `git push --no-verify`, mexer em
  `core.hooksPath` ou `hook.*`, trocar a configuração global pelo
  ambiente num commit, merge ou push, tirar `CLAUDECODE` do ambiente,
  pelo qual o pre-commit reconhece o agente), escrever as notas da
  revisão à mão e o merge pelo GitHub;
  pergunta ao autor antes de `git revisao excecao`. O portão que segura é
  o pre-push do push do autor.
- **Outros hooks da camada privada**: têm regras próprias, além da
  revisão. Siga o que a mensagem de cada um disser; nunca os pule.

## Onde a mudança vale

Os pacotes stow apontam para a árvore de trabalho: o que o ramo muda já
vale na máquina. Arquivo novo num pacote só chega ao `$HOME` depois do
`stow` do pacote, e o checkout não volta ao `main` antes do merge, ou o
link fica pendurado. Script novo em `bin/.local/bin/` chega ao `PATH` pelo
`stow -R bin`, que o `post-merge` roda, aqui e na camada privada, depois
de todo merge sem conflito no `~/.dotfiles` ou no `~/.dotfiles-private`
que muda o `bin/`, e não numa worktree.

## Testes

```sh
distrobox-host-exec sh -c 'cd ~/.dotfiles && make check'
```

Roda no host: ShellCheck e `shfmt -i 4` nos `SCRIPTS` do `Makefile`
(script de shell novo entra nessa lista) e o bats em `tests/`. Caso de
borda novo vira teste antes da correção, e todo teste novo é conferido
contra uma cópia sabotada do script, que ele tem de reprovar
(`SKILLS_SYNC_SCRIPT` e `POST_MERGE_SCRIPT` trocam o script testado).

## Commits

Em português, no imperativo, sem prefixo, o problema antes da solução e
a alternativa recusada; o commit de correção diz o que corrige. Nada de
caminho absoluto de home no que se escreve: `$HOME` ou `~`.
