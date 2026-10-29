# skills

Stow dir das skills de agente: um pacote por skill, que o `skills-sync` liga
no `$HOME` quando o perfil da máquina a lista (ver *Skills de agente* no
readme da raiz). A camada privada tem a sua, no mesmo formato, e cada skill
mora numa só.

Cada pacote `skills/<nome>/` guarda o conteúdo em `.agents/skills/<nome>/` e
dois symlinks versionados, `.claude/skills/<nome>` e `.cursor/skills/<nome>`,
os dois para `../../.agents/skills/<nome>`: o Claude Code lê só
`~/.claude/skills`, e só `~/.cursor/skills` entra no sync de Cloud Agents do
Cursor. Esse alvo é o único que resolve dentro do pacote e no `$HOME` depois
do stow.
