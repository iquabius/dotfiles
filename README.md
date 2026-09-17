# dotfiles

Minha configuração pessoal, gerenciada com [GNU Stow](https://www.gnu.org/software/stow/).
A identidade e as credenciais do git ficam numa **camada privada separada**, à parte
deste repositório e com instruções próprias.

> As instruções abaixo cobrem **macOS**. O suporte a Linux entra num passo seguinte.
> Comandos específicos de macOS estão marcados com **(macOS)**.

## Como está montado

Cada diretório na raiz é um **pacote Stow** cuja árvore espelha o `$HOME`. Rodar
`stow <pacote>` cria os symlinks correspondentes no `$HOME`.

| Pacote | O que instala |
| --- | --- |
| `fish` | `~/.config/fish` (config, plugins) |
| `emacs` | `~/.config/emacs` e `~/.config/crafted-emacs-v1` |
| `git` | `~/.gitconfig` (sem identidade — ver nota) |
| `tmux` | `~/.tmux.conf` |
| `ssh` | `~/.ssh/rc` |
| `vscode` | `~/.config/Code/User` (fonte única dos ajustes de editor) |
| `vscode-oss`, `vscodium` | apontam para o `vscode` via symlink (mesmos ajustes) |
| `latexmk` | `~/.config/latexmk` |
| `ytdlp` | `~/.config/yt-dlp` |

Detalhes que valem saber:

- **A identidade do git não está aqui.** O `.gitconfig` público não guarda
  `user.name`, `user.email` nem credenciais — isso vem de uma camada privada,
  configurada à parte.
- **VS Code é fonte única.** `Code - OSS` e `VSCodium` são symlinks internos que
  apontam para o pacote `vscode` — editar os ajustes do Code vale para os três.
- **Segredos (tokens, chaves privadas) não entram aqui.** Ficam no gerenciador de
  senhas ou cifrados com `age`.

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

### 5. Camada privada e conferência

Configure a **camada privada** à parte (identidade e credenciais do git), seguindo
as instruções dela. Em seguida confira:

```bash
git config user.email   # deve estar preenchido pela camada privada
```

Abra um terminal novo — o fish deve carregar sem erros.
