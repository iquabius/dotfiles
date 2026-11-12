# dotfiles

Minha configuração pessoal, gerenciada com [GNU Stow](https://www.gnu.org/software/stow/).
A identidade e as credenciais do git ficam na **camada privada**: o repositório
`~/.dotfiles-private`, à parte deste, com instruções próprias, que só as
máquinas pessoais têm.

> As instruções abaixo cobrem **macOS** e **Linux**. Comandos específicos de um
> ou de outro estão marcados com **(macOS)** e **(Linux)**. Os passos de Linux
> foram feitos e verificados no openSUSE Tumbleweed com fish 4.8 — em outra
> distro só muda o gerenciador de pacotes.

## Como está montado

A raiz separa o que vai para o `$HOME` do que é do próprio repositório.
`pacotes/` é a *stow dir*: cada pasta dela é um **pacote**, com a árvore que
espelha o `$HOME`. O `.stowrc` da raiz aponta o Stow para ela, e `stow
<pacote>`, rodado em `~/.dotfiles`, cria no `$HOME` os symlinks do pacote. O
resto da raiz o Stow não liga.

### Pacotes

| Pacote | O que instala |
| --- | --- |
| `fish` | `~/.config/fish` (config, plugins) |
| `emacs` | `~/.config/emacs` (precisa do crafted-emacs clonado à parte — ver *Avisos por pacote*) |
| `git` | `~/.gitconfig` (sem identidade — ver *Avisos por pacote*), com os hooks do `git-revisao` e do `git-assunto-merge` |
| `tmux` | `~/.tmux.conf` |
| `ssh` | `~/.ssh/rc` |
| `vscode` | `~/.config/Code/User` (fonte única dos ajustes de editor) |
| `vscode-oss`, `vscodium`, `cursor` | apontam para o `vscode` via symlink (mesmos ajustes) |
| `latexmk` | `~/.config/latexmk` |
| `ytdlp` | `~/.config/yt-dlp` |
| `asdf` | `~/.tool-versions` (versões globais de nodejs, pnpm, yarn, deno, erlang e elixir) |
| `darkman` | `~/.config/darkman` e os scripts de transição em `~/.local/share/{light,dark}-mode.d` **(Linux)** |
| `openwhispr` | `~/.config/autostart/openwhispr-fontconfig.desktop` e `~/.config/open-whispr/fonts.conf` **(Linux)** |
| `bin` | `~/.local/bin/`: os comandos do repositório, listados no [`pacotes/bin/readme.md`](pacotes/bin/readme.md) |
| `claude` | `~/.claude/settings.json`, que registra o `claude-revisao-guarda`; **só na máquina sem a camada privada**, que liga o dela |

### O resto da raiz

| Caminho | Papel |
| --- | --- |
| `skills/` | a outra stow dir: um pacote por skill de agente, que o `skills-sync` liga (ver *Skills de agente* e o [`skills/readme.md`](skills/readme.md)) |
| `profiles/` | os perfis de skills (`<perfil>.pkgs`), que o `skills-sync` lê |
| `scripts/` | scripts do repositório que não vão para o `$HOME`, como o `testes-da-revisao`, que o `git revisao pronto` roda |
| `tests/` | as suítes bats do hook `post-merge`, da configuração, dos `scripts/` e do `skills-sync`; o `make check` as roda junto das `*.test.bats` de `pacotes/bin/.local/bin/` |
| `Makefile` | o `make check`: ShellCheck e shfmt nos scripts de shell da lista `SCRIPTS`, e as suítes bats |
| `.githooks/` | os hooks deste repositório, ligados com `git config core.hooksPath .githooks` (ver *2. Clonar*) |
| `.config/revisao` | os caminhos que pedem a revisão do ramo antes do `main`, e o teste que o `git revisao pronto` roda |
| `.stowrc` | diz ao Stow que os pacotes estão em `pacotes/` e que o alvo é o `$HOME` |
| `AGENTS.md` (e o link `CLAUDE.md`) | as regras de trabalho: o ciclo de ramo, revisão e merge, os testes, os commits |
| `.profile.local`, `.pkgs.local` | o perfil e as skills desta máquina, fora do git (ver *Skills de agente*) |

Segredos (tokens, chaves privadas) não entram aqui: ficam no gerenciador de
senhas ou cifrados com `age`.

### Onde pôr algo novo

- **Configuração que vai para o `$HOME`:** no pacote da ferramenta, em
  `pacotes/<ferramenta>/`, no caminho que ela tem a partir do `$HOME`. A
  ferramenta nova ganha um pacote e uma linha na tabela de pacotes; o
  `stow` dela vai em *3. Aplicar os symlinks*, ou no aviso do pacote
  quando ele pede opção própria.
- **Comando para o `PATH`:** `pacotes/bin/.local/bin/<nome>`, com a suíte
  ao lado (`<nome>.test.bats`) e uma linha no
  [`pacotes/bin/readme.md`](pacotes/bin/readme.md).
- **Script que só o repositório usa:** `scripts/`.
- **Teste que não é de um comando só** (de um hook, de uma configuração, de
  vários scripts): `tests/`.
- **Skill de agente:** `skills/<nome>/`, no formato do
  [`skills/readme.md`](skills/readme.md), e o nome dela no `.pkgs` de um
  perfil em `profiles/`.

O script de shell novo, num lugar ou noutro, entra no `SCRIPTS` do
`Makefile`; o arquivo de código novo fora dos caminhos do `.config/revisao`
entra nele, para pedir a revisão do ramo.

## Avisos por pacote

### A identidade do git não está aqui

O `.gitconfig` público não guarda `user.name`, `user.email` nem credenciais —
isso vem do `~/.gitconfig.local`, configurado à parte.

### VS Code é fonte única

`Code - OSS`, `VSCodium` e Cursor são symlinks internos que apontam para o
pacote `vscode`: editar os ajustes do Code vale para os quatro, inclusive os
atalhos de teclado.

### O pacote `darkman` não guarda a localização

O `config.yaml` público não tem `lat`/`lng`: as coordenadas vêm de
`DARKMAN_LAT`/`DARKMAN_LNG`, que têm precedência sobre o arquivo e ficam num
drop-in do systemd, fora deste repo (nas máquinas pessoais, o da camada
privada):

```bash
mkdir -p ~/.config/systemd/user/darkman.service.d
cat > ~/.config/systemd/user/darkman.service.d/location.conf <<'EOF'
[Service]
Environment=DARKMAN_LAT=-00.00
Environment=DARKMAN_LNG=-00.00
EOF
chmod 600 ~/.config/systemd/user/darkman.service.d/location.conf
systemctl --user daemon-reload
systemctl --user enable --now darkman.service
```

Sem esse arquivo, ou as mesmas variáveis por outro meio, o darkman sobe e
roda, mas **nunca faz transição sozinho** — o `config.yaml` traz
`usegeoclue: false`, então não há outra fonte de localização. Confira com
`systemctl --user status darkman.service`: o log imprime o próximo nascer e
pôr do sol, e um sinal trocado aparece ali e em mais lugar nenhum.

### O pacote `openwhispr` contorna o fontconfig embutido do app

O OpenWhispr traz um libfontconfig mais velho que não lê os caches do sistema,
e a janela abre sem texto. A entrada de autostart do pacote o lança com
`FONTCONFIG_FILE` apontando para um `fonts.conf` que declara um cache
próprio. Ela tem nome diferente do `open-whispr.desktop` do app porque o app
pode reescrever aquele ao abrir; por isso o "iniciar com o sistema" das
preferências dele fica desligado. Instale com `--no-folding`: sem ele, numa
máquina onde `~/.config/open-whispr` ainda não existe, o Stow faz do diretório
um symlink para cá, e o app passa a gravar banco, logs e o `.env` com token
dentro deste repo:

```bash
cd ~/.dotfiles && stow --no-folding openwhispr
```

### O pacote `emacs` não é autossuficiente

O `init.el` carrega `~/.config/crafted-emacs/modules/…`, que não está neste
repo — é preciso clonar
[crafted-emacs](https://github.com/SystemCrafters/crafted-emacs) à parte:

```bash
git clone https://github.com/SystemCrafters/crafted-emacs ~/.config/crafted-emacs
```

Para testar a configuração sem janela, carregue o init de verdade no
host, onde o Emacs roda (num contêiner, por `distrobox-host-exec`):

```bash
emacs --batch -l ~/.config/emacs/early-init.el --eval '(package-activate-all)' \
    -l ~/.config/emacs/init.el -l teste.el
```

Sem o `package-activate-all`, o `require` do ergoemacs falha; o
`teste.el` que lê variáveis locais de arquivo começa com `(setq
enable-local-variables :all)`.

Função ou variável nova do init leva o prefixo `gambi/`
(`gambi/org-tex-commented-p`); as antigas com `my/` ficam como estão,
até alguém pedir para renomeá-las.

### O `fish_plugins` não instala nada sozinho

O fisher não vem versionado aqui; enquanto não for instalado à mão, o arquivo
fica inerte (ver *5. Plugins do fish*).

## Skills de agente

As skills de agente (Claude Code, Codex, Cursor) vêm de dois repositórios:
este e a camada privada, em `~/.dotfiles-private`, que só as máquinas
pessoais têm. Cada um tem a sua stow dir `skills/`, com um pacote por skill,
e os seus `profiles/<perfil>.pkgs`; a maior parte mora aqui, e as que ficam
privadas moram na camada privada. O `skills-sync` liga em `~/.agents/skills`,
`~/.claude/skills` e `~/.cursor/skills` as skills dos perfis que o
`.profile.local` daqui lista, e
desliga as que saíram do perfil, sumiram dos repositórios ou mudaram de um ao
outro.

- Um perfil é a união dos `.pkgs` de mesmo nome nos dois repositórios: o
  `comum.pkgs` daqui lista o que vale em toda máquina, e o da camada privada
  soma o que só as máquinas pessoais ligam.
- Cada skill mora num repositório só; a skill do perfil que está nos dois é
  erro, antes de mexer em qualquer link.
- O `.profile.local` e o `.pkgs.local` que ficaram na camada privada também
  são erro: o `skills-sync` diz o `mv` que os traz.
- O `.pkgs.local` daqui liga skills só nesta máquina. Ele e o
  `.profile.local` ficam fora do git.
- Na máquina de onde a camada privada saiu, os links que apontavam para ela
  saem no sync seguinte.

```bash
printf 'comum\ntrabalho\n' > ~/.dotfiles/.profile.local   # ou 'comum\npessoal\n', com a camada privada
skills-sync        # aplica
skills-sync -n     # só mostra o que faria
```

O `post-merge` dos dois repositórios o roda depois do pull que muda as
skills ou os perfis. O `pull --rebase` que reaplica commits locais, o pull
com conflito e o `git reset` para o remoto não chamam o `post-merge`: aí é
rodar o `skills-sync` à mão.

## Reconfigurar num sistema novo (ou formatado)

### 1. Pré-requisitos

**(macOS)** Instalar o Homebrew, se ainda não tiver:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**(macOS)** Instalar git, Stow e o GitHub CLI. Os hooks do pacote `git`
(`[hook "..."]`) pedem o git 2.54 ou mais novo: confira com `git
--version` que o do Homebrew vem antes no `PATH`:

```bash
brew install git stow gh
```

**(Linux)** Instalar o Stow e o que os pacotes pedem. No openSUSE Tumbleweed
está tudo no repositório OSS — sem Homebrew, sem repo de terceiro:

```bash
sudo zypper install -y stow fish tmux git-delta starship zoxide fzf gh yt-dlp
```

Em Debian/Ubuntu e Fedora os nomes são quase os mesmos; a exceção é o `delta`,
que o `.gitconfig` usa como pager e o RPM chama de **`git-delta`** (`apt`:
`git-delta`; binário `delta` nos dois). `starship` e `zoxide` são opcionais
— o `config.fish` guarda cada um com `type -q`; o `fzf` é dependência do
plugin `fzf.fish` do `fish_plugins`.

Nenhuma variante do VS Code está nos repos do Tumbleweed: para usar os pacotes
`vscode*`, instale o Code pelo repo da Microsoft ou o VSCodium pelo dele.

Autenticar no GitHub:

```bash
gh auth login
```

### 2. Clonar

```bash
git clone https://github.com/iquabius/dotfiles.git ~/.dotfiles
```

Ligue os hooks logo depois de clonar — `core.hooksPath` é config local, não vem
junto no clone:

```bash
cd ~/.dotfiles && git config core.hooksPath .githooks
```

O `pre-commit` recusa `/home/<user>/` e `/Users/<user>/` nas linhas
adicionadas: caminho absoluto de home entrega o nome da conta da máquina que
escreveu a linha, e três já tinham entrado aqui desse jeito. Só as linhas
novas são olhadas, e `git commit --no-verify` passa por cima quando for
mesmo o caso. O `post-merge` roda o `stow -R bin`, daqui e da camada
privada, depois de todo pull que muda o pacote `bin` de um dos dois, e o
`skills-sync` depois de todo pull que muda as skills, os perfis ou o próprio
`skills-sync` (ver *Skills de agente*); numa worktree ou num clone fora do
`~/.dotfiles`, nada.

### 3. Aplicar os symlinks

Instale só os pacotes que fizerem sentido na máquina:

```bash
cd ~/.dotfiles && stow fish emacs git tmux ssh latexmk ytdlp asdf
cd ~/.dotfiles && stow --no-folding vscode vscode-oss vscodium cursor
mkdir -p ~/.local/bin && cd ~/.dotfiles && stow bin
mkdir -p ~/.claude && cd ~/.dotfiles && stow claude   # só sem a camada privada
```

O `mkdir` vem antes do `stow bin`: sem `~/.local/bin`, o Stow faz dele um
symlink para dentro deste repo, e todo script que outro pacote ligasse ali
cairia aqui dentro. O mesmo vale para o `~/.claude`, onde o Claude Code
grava histórico e projetos. Na máquina com a camada privada, o
`~/.claude/settings.json` vem do pacote dela, que registra também os
guardas de lá, e o `claude` daqui fica sem ligar.

Os editores exigem `--no-folding`. Sem ele, numa máquina onde
`~/.config/Code` (ou `Cursor`) ainda não existe, o Stow cria o diretório
inteiro como um symlink para dentro deste repo, e o editor passa a gravar
histórico, cache e `workspaceStorage` aqui dentro. Com `--no-folding` os
diretórios são reais e só os `.json` viram symlink.

**(macOS)** No Mac, Code e Cursor leem de `~/Library/Application Support`, não
de `~/.config`. Ligue os dois `.json` de lá aos que o Stow criou (tire da
frente os arquivos que já existirem):

```bash
for app in Code Cursor; do
  d="$HOME/Library/Application Support/$app/User"
  mkdir -p "$d"
  for f in settings.json keybindings.json; do
    ln -sn "../../../../.config/$app/User/$f" "$d/$f"
  done
done
```

### 4. Se o Stow reclamar de conflito

O Stow é atômico: um único arquivo preexistente aborta o pacote inteiro. Tire o
arquivo da frente e repita o `stow`:

```bash
mkdir -p ~/.dotfiles-backup
mv "<arquivo em conflito>" ~/.dotfiles-backup/
```

Dois conflitos são quase certos numa máquina já usada:

- **`~/.gitconfig`** — normalmente já existe com a identidade dentro. Mova a
  identidade para `~/.gitconfig.local` (incluído no fim do
  `.gitconfig` público) antes de tirar o arquivo da frente.
- **`~/.emacs`** — se existir, o Emacs **ignora** `~/.config/emacs` e não avisa:
  o caminho XDG só vale quando não há `~/.emacs`, `~/.emacs.el` nem
  `~/.emacs.d/init.el`. O Stow não reclama disso, porque não é um alvo dele.
  Apague ou renomeie antes de usar o pacote `emacs`.

### 5. Plugins do fish

O fisher não vem no clone, então o `fish_plugins` não faz nada até ser
instalado. Depois disso ele lê o arquivo e instala os seis de uma vez:

```bash
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
fish -c 'fisher update'
```

O Stow dobra `~/.config/fish` num symlink só, então tudo que o fish escreve
(plugins, completions, `fish_variables`) cai **dentro deste repo** — o
`.gitignore` de `pacotes/fish/.config/fish` cobre esses arquivos.

**(Linux)** Para usar o fish como shell de login:

```bash
chsh -s /usr/bin/fish    # pede a sua senha, não a de root
```

### 6. Ferramentas do asdf

O pacote `asdf` traz só o `~/.tool-versions`; o asdf em si vem de fora.
**(macOS)** `brew install asdf`. **(Linux)** siga a instalação do site do
asdf. O `config.fish` põe os shims no `PATH` quando o `asdf` existe.

O asdf não tem arquivo de plugins, e `asdf install` falha para ferramenta
sem plugin. A primeira coluna do `.tool-versions` é o nome curto de cada
plugin, então o próprio arquivo serve de lista:

```bash
cut -d' ' -f1 ~/.tool-versions | xargs -n1 asdf plugin add
cd ~ && asdf install
```

O `erlang` compila do fonte e demora; as dependências de build estão no
README do asdf-erlang. O `elixir` vem pré-compilado, mas o sufixo
`-otp-28` pede o Erlang 28 do mesmo arquivo.

Se o deno também estiver instalado pelo Homebrew, vale o do asdf: os shims
entram antes no `PATH`.

### 7. Camada privada e conferência

A identidade e as credenciais do git vão no `~/.gitconfig.local`: nas
máquinas pessoais, configure a **camada privada**, seguindo as instruções
dela, que o liga; nas outras, escreva-o à mão. Como o `[include]` dele é a
**última** diretiva do `.gitconfig` público, ele também serve de override
por máquina — útil porque o `core.editor` daqui é `cursor --wait` e o
difftool é o `code`, que nem sempre existem:

```ini
# ~/.gitconfig.local, numa máquina sem Cursor nem VS Code
[core]
	editor = nano
[diff]
	tool = vimdiff
```

Em seguida confira:

```bash
git config user.email   # deve vir do ~/.gitconfig.local
git config core.pager   # delta
fish -c 'fisher list'   # seis plugins
```

Abra um terminal novo — o fish deve carregar sem erros.
