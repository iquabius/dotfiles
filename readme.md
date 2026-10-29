# dotfiles

Minha configuração pessoal, gerenciada com [GNU Stow](https://www.gnu.org/software/stow/).
A identidade e as credenciais do git ficam numa **camada privada separada**, à parte
deste repositório e com instruções próprias.

> As instruções abaixo cobrem **macOS** e **Linux**. Comandos específicos de um
> ou de outro estão marcados com **(macOS)** e **(Linux)**. Os passos de Linux
> foram feitos e verificados no openSUSE Tumbleweed com fish 4.8 — em outra
> distro só muda o gerenciador de pacotes.

## Como está montado

Cada diretório na raiz é um **pacote Stow** cuja árvore espelha o `$HOME`. Rodar
`stow <pacote>` cria os symlinks correspondentes no `$HOME`.

| Pacote | O que instala |
| --- | --- |
| `fish` | `~/.config/fish` (config, plugins) |
| `emacs` | `~/.config/emacs` (precisa do crafted-emacs clonado à parte — ver nota) |
| `git` | `~/.gitconfig` (sem identidade — ver nota), com os hooks do `git-revisao` e do `git-assunto-merge` |
| `tmux` | `~/.tmux.conf` |
| `ssh` | `~/.ssh/rc` |
| `vscode` | `~/.config/Code/User` (fonte única dos ajustes de editor) |
| `vscode-oss`, `vscodium`, `cursor` | apontam para o `vscode` via symlink (mesmos ajustes) |
| `latexmk` | `~/.config/latexmk` |
| `ytdlp` | `~/.config/yt-dlp` |
| `asdf` | `~/.tool-versions` (versões globais de nodejs, pnpm, yarn, deno, erlang e elixir) |
| `darkman` | `~/.config/darkman` e os scripts de transição em `~/.local/share/{light,dark}-mode.d` **(Linux)** |
| `openwhispr` | `~/.config/autostart/openwhispr-fontconfig.desktop` e `~/.config/open-whispr/fonts.conf` **(Linux)** |
| `bin` | `~/.local/bin/`: `skills-sync`, que liga as skills de agente do perfil da máquina (ver *Skills de agente*); `git-revisao`, que guarda o ciclo de ramo, revisão e merge do `AGENTS.md`; `git-assunto-merge`, que exige o assunto do commit de merge em português; e `claude-revisao-guarda`, o hook do Claude Code que recusa pular os hooks do git |
| `claude` | `~/.claude/settings.json`, que registra o `claude-revisao-guarda`; **só na máquina sem a camada privada**, que liga o dela |

Detalhes que valem saber:

- **A identidade do git não está aqui.** O `.gitconfig` público não guarda
  `user.name`, `user.email` nem credenciais — isso vem de uma camada privada,
  configurada à parte.
- **VS Code é fonte única.** `Code - OSS`, `VSCodium` e Cursor são symlinks
  internos que apontam para o pacote `vscode`: editar os ajustes do Code vale
  para os quatro, inclusive os atalhos de teclado.
- **O pacote `darkman` não guarda a localização.** O `config.yaml` público não
  tem `lat`/`lng`: as coordenadas vêm de `DARKMAN_LAT`/`DARKMAN_LNG`, que têm
  precedência sobre o arquivo e ficam numa camada privada, fora deste repo:

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

  Sem esse arquivo o darkman sobe e roda, mas **nunca faz transição** — o
  `config.yaml` traz `usegeoclue: false`, então não há outra fonte de
  localização. Confira com `systemctl --user status darkman.service`: o log
  imprime o próximo nascer e pôr do sol, e um sinal trocado aparece ali e em
  mais lugar nenhum.
- **O pacote `openwhispr` contorna o fontconfig embutido do app.** O
  OpenWhispr traz um libfontconfig mais velho que não lê os caches do sistema,
  e a janela abre sem texto. A entrada de autostart do pacote o lança com
  `FONTCONFIG_FILE` apontando para um cache próprio. Ela tem nome diferente do
  `open-whispr.desktop` do app porque o app reescreve aquele a cada partida;
  por isso o "iniciar com o sistema" das preferências dele fica desligado.
  Instale com `--no-folding`: sem ele, numa máquina onde `~/.config/open-whispr`
  ainda não existe, o Stow faz do diretório um symlink para cá, e o app passa a
  gravar banco, logs e o `.env` com token dentro deste repo:

  ```bash
  cd ~/.dotfiles && stow --no-folding openwhispr
  ```
- **`.githooks/` não é pacote Stow.** É hook de repositório, ligado com
  `git config core.hooksPath .githooks` (passo 2) — não vai para o `$HOME`.
- **`.config/` também não.** O `.config/revisao` lista os caminhos de código
  que pedem revisão do ramo antes do `main`; o ciclo está no `AGENTS.md`.
- **`profiles/` também não.** Os perfis de skills de agente, lidos pelo
  `skills-sync` (ver *Skills de agente*).
- **`scripts/` também não.** Scripts do repositório que não vão para o
  `$HOME`, como o `testes-da-revisao`, que o `git revisao pronto` roda.
- **Segredos (tokens, chaves privadas) não entram aqui.** Ficam no gerenciador de
  senhas ou cifrados com `age`.
- **O pacote `emacs` não é autossuficiente.** O `init.el` carrega
  `~/.config/crafted-emacs/modules/…`, que não está neste repo — é preciso clonar
  [crafted-emacs](https://github.com/SystemCrafters/crafted-emacs) à parte:

  ```bash
  git clone https://github.com/SystemCrafters/crafted-emacs ~/.config/crafted-emacs
  ```
- **O `fish_plugins` não instala nada sozinho.** O fisher não vem versionado
  aqui; enquanto não for instalado à mão, o arquivo fica inerte (passo 5).

## Skills de agente

As skills de agente (Claude Code, Codex, Cursor) vêm de dois repositórios:
este e a camada privada, em `~/.dotfiles-private`, que só as máquinas
pessoais têm. Cada um tem a sua stow dir `skills/`, com um pacote por skill,
e os seus `profiles/<perfil>.pkgs`; por ora, todas as skills estão na camada
privada. O `skills-sync` liga em `~/.agents/skills`, `~/.claude/skills` e
`~/.cursor/skills` as skills dos perfis que o `.profile.local` daqui lista, e
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
`git-delta`; binário `delta` nos dois). `starship`, `zoxide` e `fzf` são
opcionais — o `config.fish` guarda cada um com `type -q`.

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
  identidade para `~/.gitconfig.local` (a camada privada, incluída no fim do
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
`.gitignore` de `fish/.config/fish` cobre esses arquivos.

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

Configure a **camada privada** à parte (identidade e credenciais do git), seguindo
as instruções dela. Como o `[include]` dela é a **última** diretiva do
`.gitconfig` público, ela também serve de camada de override por máquina — útil
porque o `core.editor` daqui é `cursor --wait` e o difftool é o `code`, que nem
sempre existem:

```ini
# ~/.gitconfig.local, numa máquina sem Cursor nem VS Code
[core]
	editor = nano
[diff]
	tool = vimdiff
```

Em seguida confira:

```bash
git config user.email   # deve estar preenchido pela camada privada
git config core.pager   # delta
fish -c 'fisher list'   # seis plugins
```

Abra um terminal novo — o fish deve carregar sem erros.
