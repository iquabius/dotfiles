# bin

Comandos que o stow liga em `~/.local/bin`. O `skills-sync` está no
[readme da raiz](../readme.md) (*Skills de agente*). Este arquivo e os testes
(`*.test.bats`) ficam fora do `~/.local/bin` pelo `.stow-local-ignore`.

## git-revisao e claude-revisao-guarda

Código só chega ao `main` (ou `master`) de um ramo revisado com a skill
`revisao-rigorosa`. O ciclo inteiro, de ramo a merge, está no
[AGENTS.md](../AGENTS.md); a decisão é de 2026-10-07. Duas peças o guardam.

### git-revisao

Vale no repositório que lista os caminhos de código em `.config/revisao`, um
pathspec do git por linha (`#` comenta; diretório com curinga termina em
`/*`), e ali declara, numa linha `teste: <comando>`, o teste do `pronto`.
Repositório sem o arquivo fica de fora. A própria lista está nela, para que
estreitá-la também passe pela revisão; e o pre-push junta a lista do remoto
à da ponta, para que um push não a estreite e passe com o que ela deixou de
fora.

- `git revisao pronto [<ponta>]`: marca a ponta revisada com o veredito
  *Pronto para o merge*, depois de o teste do repositório passar. O teste é a
  linha `teste: <comando>` do `.config/revisao` da ponta, ou do `main` se o
  ramo a tirou; roda sempre que há um declarado, da raiz, pelo `sh`, com
  `GIT_REVISAO_BASE` e `GIT_REVISAO_PONTA` no ambiente. O comando escolhe
  pelo diff o que conferir, inclusive o que a lista não conta como código, e
  sai com 0 quando nada pede conferência; o `scripts/testes-da-revisao`
  daqui faz isso pela forma do repositório e serve também à camada privada.
  Como roda no checkout, o `pronto` com teste pede que a ponta seja o `HEAD`
  e que nenhum caminho de código tenha mudança fora do commit, nem arquivo
  novo; o rascunho de texto pode ficar. Falhou, não marca. A marca é uma
  nota em `refs/notes/revisao`, com o veredito, a base e a data, e cobre os
  commits de base até a ponta. A base é o merge-base com o `main`; para uma
  ponta que já está na linha do `main`, o merge-base com o `main` do remoto;
  sem remoto configurado (`main@{upstream}`), a marca cobre desde a raiz, e
  a saída diz isso. Vale a marca cuja ponta e cuja base existem no clone.
- `git revisao excecao -m <motivo> [<ponta>]`: a mesma marca, para o que vai
  sem o *Pronto para o merge*: um achado que o autor deixou de pé, um
  teste que não dá para rodar, ou commits anteriores a esta regra. Não roda o teste.
- `git revisao pendente [<ponta>]`: lista o código que um push da ponta
  levaria ao `main` sem marca que o cubra; sai com 1 se houver.
- **pre-push** (`[hook "revisao-push"]` do pacote `git`): recusa o push ao
  `main` ou `master` que leve commit de código sem marca. Merge conta só
  pelo diff `--cc`, que fica vazio quando nenhum conflito foi resolvido à
  mão; quando não fica, a resolução se revisa (`git show --cc`) antes da
  marca. Também recusa enviar `refs/notes/revisao`: as notas ficam no clone.
- **pre-commit** (`[hook "revisao-commit"]`): recusa o commit de agente
  (`CLAUDECODE` no ambiente, como no Bash do Claude Code) no `main` que
  mexa no código; o que entra no commit vem do índice, então `git commit
  -a` e `git commit -- <arquivos>` contam. Concluir um merge passa. O git
  não chama o pre-commit em `cherry-pick`, `revert` nem `am`; o que eles
  levarem ao `main` fica para o pre-push.

Reescrever um commit marcado, como faz o rebase que só refaz as datas ou as
mensagens, muda o sha, mas não tira a marca: o commit com a mesma árvore e
as mesmas árvores dos pais de um commit coberto conta como coberto, porque
o código e o diff são os que a revisão viu. O que muda algum arquivo, no
commit ou no pai (o `cherry-pick` depois de o `main` andar), pede revisão
de novo. A herança dura enquanto o commit marcado existir no clone; o gc o
leva depois que o reflog expira.

### claude-revisao-guarda

Hook PreToolUse do Bash, registrado no `~/.claude/settings.json` pelo
pacote `claude` ou pelo da camada privada. Recusa o que o git não vê: `git
commit --no-verify` ou `-n` (também abreviado ou agrupado) e `git push`,
`merge` ou `pull` com `--no-verify`, também abreviado; o alias gravado
pelo `git config` que faria uma dessas coisas, conferido quando se grava;
mexer em `hook.*` da configuração, que liga os hooks do `git-revisao` e do
`git-assunto-merge`, em `core.hooksPath` (ou na seção `core`), que desliga
os hooks do repositório, ou em `include.*`, que traz outra configuração;
trocar a configuração global pelo ambiente (`GIT_CONFIG_GLOBAL`,
`GIT_CONFIG_COUNT`, `HOME`), atribuída no começo de um comando, solta ou
com `export`, `declare -x`, `env` ou `env -S`, ou tirada com `env -u`,
antes de um git que commita, junta, puxa ou envia, que desliga os da
configuração; tirar `CLAUDECODE` do ambiente (`unset`, `env -u`, `env
CLAUDECODE=`, `env -i`, `export -n`); escrever `refs/notes/revisao` sem o
`git revisao`; e o merge pelo GitHub (`gh pr merge`, a API REST ou a
GraphQL), que não passa pelo pre-push. Ler a configuração (`get`,
`list`, `--get*`, `--list`, a chave sozinha) passa, também com
redirecionamento.

O comando se separa em palavras com as regras do shell que mudam o que
roda: as aspas protegem o que está dentro, o separador entre aspas não
corta o comando, o `#` no começo de uma palavra abre um comentário, a
barra no fim da linha, fora de comentário, a junta à seguinte, e os
redirecionamentos saem. Todas as regras leem essas palavras. Cada chamada
do git se lê palavra por palavra: a opção longa abreviada (`--unset-a`,
`--no-verif`) conta como a inteira, e o argumento de uma opção (`-m`,
`-o`, `-t`) não conta como opção. O texto de `sh -c`, `bash -c`, `bash
<<<`, `eval`, da substituição de comando (`` `...` `` e `$(...)`, também
entre aspas duplas, não entre simples), do heredoc que um shell lê (`bash
<<'EOF'`) e do alias de um `-c alias.<nome>=` usado como subcomando se
confere como mais um comando, com o ambiente que ele recebe; e `env` (com
`-S`), `command`, `exec`, `nohup`, `time`, `sudo`, `nice`, `timeout`,
`xargs` e as palavras do shell (`if`, `then`, `do`, `{`, `!`) na frente
do git não o escondem. O corpo de heredoc mandado a outro programa é
texto: com o delimitador entre aspas (`<<'EOF'`), o shell não o expande;
sem aspas, só o `$(...)` dele roda, e só ele se confere. Antes de `git
revisao excecao`, pergunta ao autor.

São as formas diretas. Passam por todas: um script gravado em arquivo e
depois executado, o git chamado por uma variável (`$G config`) e os
argumentos ou o comando que chegam por um pipe ao `xargs` ou a um shell
(`printf ... | bash`). Passam também, por ora, formas que a revisão
achou e que o guarda ainda não lê: o `-c` que não vem logo depois das
opções do shell (`bash -c -x '...'`), outros shells (`fish -c`, `ksh
-c`), opções globais do git que ele não conhece (`--attr-source`), o
ambiente que um `eval` exporta para os comandos seguintes, prefixos fora
da lista (`setsid`, `stdbuf`, `builtin`), o `source` ou `.` de um
heredoc, o `<<<` antes do subcomando do git e a ordem de precedência
entre `GIT_NOTES_REF`, `-c core.notesRef` e `--ref`. Do outro lado, ele
recusa a mais em dois casos: a troca de ambiente dentro de um subshell
(`( HOME=/x; ...)`) vale para os comandos de fora, e a substituição de
comando se confere com o ambiente do fim do comando. O portão que segura
é o pre-push do push, que é do autor.

### Testes

`git-revisao.test.bats` e `claude-revisao-guarda.test.bats`, ao lado dos
scripts. A primeira cria repositórios e remotos descartáveis, com os hooks
no `.git/hooks` de cada um; a segunda só manda comandos ao hook.
`GIT_REVISAO_SCRIPT` e `CLAUDE_REVISAO_GUARDA_SCRIPT` apontam a suíte para
uma cópia sabotada.

## git-assunto-merge

O pacote `git` liga o hook global `commit-msg` (`[hook "assunto-merge"]`,
git 2.54 ou mais novo), que o git chama no `git commit` e no `git merge`.
Ele recusa o assunto "Merge branch '<ramo>'", com ou sem " into <ramo>", que
o git escreve quando o merge vem sem `-m`, e o "Junta o ramo <ramo>:" que
não diz o que o ramo traz. O merge recusado fica por concluir, e a recusa
dá o `git commit -m "Junta o ramo <ramo>: <o que o ramo traz>"` que o
conclui; no `git commit --amend` de um merge já feito (sem `MERGE_HEAD`),
dá o `git commit --amend -m`, que mantém os pais. O merge de um pull ("Merge
branch '<ramo>' of <url>"), o de um ramo remoto ("Merge remote-tracking
branch"), o de vários ramos ("Merge branches"), o de um commit e o de uma
tag passam: a regra é do merge de um ramo de tarefa. Vale em todo
repositório; um repositório sai com `git config hook.assunto-merge.enabled
false`.

`git-assunto-merge.test.bats`, ao lado do script, cria um repositório
descartável com o hook no `.git/hooks`; `GIT_ASSUNTO_MERGE_SCRIPT` aponta a
suíte para uma cópia sabotada.
