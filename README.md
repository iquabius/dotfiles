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
| `git` | `~/.gitconfig` (sem identidade — ver nota) |
| `tmux` | `~/.tmux.conf` |
| `ssh` | `~/.ssh/rc` |
| `vscode` | `~/.config/Code/User` (fonte única dos ajustes de editor) |
| `vscode-oss`, `vscodium` | apontam para o `vscode` via symlink (mesmos ajustes) |
| `latexmk` | `~/.config/latexmk` |
| `ytdlp` | `~/.config/yt-dlp` |
| `darkman` | `~/.config/darkman` e os scripts de transição em `~/.local/share/{light,dark}-mode.d` **(Linux)** |

Detalhes que valem saber:

- **A identidade do git não está aqui.** O `.gitconfig` público não guarda
  `user.name`, `user.email` nem credenciais — isso vem de uma camada privada,
  configurada à parte.
- **VS Code é fonte única.** `Code - OSS` e `VSCodium` são symlinks internos que
  apontam para o pacote `vscode` — editar os ajustes do Code vale para os três.
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

## Reconfigurar num sistema novo (ou formatado)

### 1. Pré-requisitos

**(macOS)** Instalar o Homebrew, se ainda não tiver:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**(macOS)** Instalar git, Stow e o GitHub CLI:

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

### 3. Aplicar os symlinks

Instale só os pacotes que fizerem sentido na máquina:

```bash
cd ~/.dotfiles && stow fish emacs git tmux ssh vscode vscode-oss vscodium latexmk ytdlp
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

### 6. Camada privada e conferência

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
