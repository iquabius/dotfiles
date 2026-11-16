# Ergonomia e hierarquia — a lente medida

Esta é a lente que rendeu os melhores achados desta skill: um botão primário
escondido sob uma barra de abas sticky, controles secundários largados no
terço superior, de difícil alcance. Eles foram achados medindo, não olhando.
Daí a regra: **uma afirmação de alcance, oclusão, tamanho ou hierarquia vem
com pixels quando há uma ferramenta de navegador; sem ela, a afirmação sai
com o grau `[Julgamento]` e o declara.**

## Pisos

Os números são canônicos em `acessibilidade.md`; ao mudá-los, atualize também
as repetições: alvos de toque de 44×44 px com espaçamento contra o toque
errado, texto corrido de 16 px no celular (18 px de preferência para a
persona ingênua), contraste de texto de 4,5:1 (3:1 para texto grande e
interface), a cor nunca como único portador, nenhuma rolagem horizontal a
320 px. Abaixo de um piso, com grau `[Medido]` ou `[Observado]`, é falha de
**portão** (passo 1 do SKILL.md), não um achado com nota. Acima do piso, o
tamanho ainda pesa na severidade: um alvo de 44 px na zona difícil é
alcançável mas custoso, e um botão em linha de 38 px ao lado de um primário
de 48 px diz à persona qual ação o produto acha que importa.

## A zona do polegar (alcance com uma mão)

Num celular segurado com uma mão, o polegar varre um arco a partir da base.
A zona **natural** é a faixa de baixo, no centro; a zona de **esforço** é o
meio e o lado mais próximo; a zona **difícil** são os 30 % superiores e o
canto de cima mais distante. A Smashing Magazine (2016) e a Parachute Design
descrevem uma zona **combinada**, confortável para destros e canhotos: a
faixa de baixo, no centro, estreitando-se para os lados. Ponha ali as ações
que a persona faz em toda visita; ponha as raras (um controle de
demonstração, um replay, as configurações) nos cantos difíceis, onde não
custa nada alcançá-las uma vez por semana.

**Modelo da casa para um viewport retrato de 375×812** (uma heurística para
calcular contra, não ciência citada; diga isso no cartão):

- natural: y ≥ 55 % da altura do viewport, x dentro dos 70 % centrais
- esforço: 30 % ≤ y < 55 %, ou os 15 % externos da largura na faixa natural
- difícil: y < 30 %, e qualquer canto de cima

Escale as porcentagens com o viewport; não carregue números em pixels de um
aparelho para outro. No desktop o modelo é outro: o alcance é o mouse, o
custo é a atenção, e a zona difícil é tudo o que o olho não visita (abaixo
da dobra, na extrema direita de um layout largo).

Regra de posição: **ação frequente na zona natural; ação rara num canto
difícil; nunca o contrário.** Uma ação frequente na zona difícil é um achado
(`ALCANCE-DO-POLEGAR`); um controle raro de demonstração na faixa natural, onde
deveria estar uma ação frequente, também é (`RARO-NO-NOBRE`).

## Oclusão e espaço reservado

Barras sticky e fixas (barras de abas, cabeçalhos, toasts, teclados) cobrem o
conteúdo. Meça o retângulo da barra e o de cada elemento acionável; todo
elemento acionável cujo retângulo cruza o de uma barra em repouso, ou que
fica abaixo da dobra sem indicação de rolagem, é `ENCOBERTO`. O conserto
costuma ser um preenchimento reservado igual à altura da barra mais uma
margem, ou mover a ação. O caso canônico: um botão primário em y 759–797
sob uma barra de abas em 754–812, num viewport de 812 px. Ele parecia
presente no arquivo de design e era inalcançável na renderização.

## Hierarquia visual (o que se vê primeiro)

As ferramentas, cada uma mensurável ou ao menos apontável (a partir do
`visual-hierarchy` da owl-listener):

- **Tamanho.** O maior atrai primeiro; um degrau claro é de pelo menos 1,5×.
- **Peso.** Negrito, traços mais grossos e ícones preenchidos carregam mais.
- **Cor e contraste.** O contraste alto atrai; use-o para a ação primária e
  o status, não para decorar.
- **Espaçamento.** O espaço em branco em volta de um elemento aumenta a
  importância dele.
- **Posição.** O canto de cima à esquerda é visto primeiro nos layouts da
  esquerda para a direita; a dobra importa; os padrões de leitura em F e
  em Z.
- **Densidade.** Elementos isolados se destacam; elementos agrupados se leem
  como uma unidade.

Quatro níveis: **primário** (o título da tela e a única ação primária
dela), **secundário** (títulos de seção, o conteúdo-chave), **terciário**
(texto de apoio, metadados), **quaternário** (letras miúdas, carimbos de
hora). Uma tela em que dois elementos disputam o nível primário, ou em que a
ação primária está no nível terciário, é `HIERARQUIA-PLANA` ou `UMA-PRIMARIA`.

**O teste de apertar os olhos.** Desfoque a captura de tela (ou tire-a a
25 % da escala). A hierarquia tem de sobreviver: o título, a ação, as
seções. Se tudo vira um mingau cinza ou duas coisas gritam, o achado está
ali antes de se nomear qualquer heurística.

**Uma ação primária por vista.** Não é preferência de estilo: duas primárias
fazem a persona escolher antes de entender, que é a lei 1 de Krug em
pixels.

**Use a hierarquia para contar uma história.** A revisão estima a ordem de
leitura sugerida pela posição e pelo peso e a compara com a ordem de que a
tarefa precisa. A ordem efetiva exige observação do olhar. Um desencontro é
um achado. Uma espinha que funcionou em telas de status: veredito → pessoas
→ ação → tendência. O padrão é um exemplo, não uma regra.

## O protocolo de medição

Com uma ferramenta de navegador ou de DevTools (o MCP chrome-devtools, o
Playwright, o navegador embutido):

1. **Emule o aparelho, não a janela.** Ajuste o viewport com as métricas do
   aparelho (padrão 375×812 px CSS com DPR 3, emulação de celular e de toque;
   desktop 1440×900). Redimensionar a janela do navegador não é a mesma
   coisa: janelas têm largura mínima e não têm toque, e a primeira passada
   de medição vai para o lixo. No MCP chrome-devtools, isso é a ferramenta
   `emulate` com uma especificação de viewport, não `resize_page`.
2. Recarregue para o layout ficar em repouso. Percorra os estados de que a
   tarefa precisa: em repouso, depois de cada ação, os estados de erro e de
   vazio, e uma primeira visita a frio com a camada de primeiro uso
   aberta, se houver. Capture os retângulos e uma captura de tela em cada um.
3. Para cada elemento acionável e cada região sticky ou fixa, registre
   `getBoundingClientRect()` (x, y, largura, altura), mais `offsetParent`
   quando o posicionamento sticky puder deslocar o retângulo.
4. Calcule: o tamanho do alvo contra o piso; a sobreposição entre os
   retângulos acionáveis e os das barras; a zona, pelo modelo acima; a razão
   de tamanho entre a ação primária e as concorrentes.
5. Tire a captura de tela que os números descrevem, no mesmo viewport, e
   guarde-a com o relatório. Se a ferramenta de captura só grava dentro do
   projeto, grave ali e depois mova o arquivo para junto do relatório;
   nunca o deixe na árvore de trabalho.
5b. Calcule o contraste com a fórmula de luminância relativa da WCAG
   (receita em `acessibilidade.md`); não o leia na tela.
6. Dê ao cartão o grau `[Medido]` quando os números vierem do passo 3;
   `[Observado]` quando você viu a renderização mas não extraiu os
   retângulos; `[Julgamento]` quando raciocinou a partir de uma imagem
   estática. Um portão só reprova com `[Medido]` ou `[Observado]`; com
   `[Julgamento]`, registre "medição pendente" em "Não avaliado", sem
   reprovar o portão.

Sem ferramenta de navegador, diga na linha "não avaliado" do relatório quais
destes passos você não pôde dar, e dê o grau de acordo. Não estime pixels a
partir de uma captura de tela para chamá-los de medidos.

**Um só dono do navegador.** Um app vivo tem estado. O orquestrador roda
esta passada uma vez e entrega às lentes os retângulos, as capturas e as
notas de estado; os agentes das lentes nunca dirigem a página eles mesmos,
ou o toque de uma lente muda o que outra está medindo.

## Achados que esta lente costuma emitir

`ALCANCE-DO-POLEGAR` · `RARO-NO-NOBRE` · `ENCOBERTO` · `TAMANHO-DO-ALVO` (portão) ·
`UMA-PRIMARIA` · `HIERARQUIA-PLANA` · `ORDEM-TROCADA`. Definições em
`checagens.md`.
