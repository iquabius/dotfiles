# Acessibilidade — o piso, as falhas e o que não se vê

Duas coisas diferentes têm o mesmo nome. O **piso** é um portão: abaixo dele
o design é inutilizável para o membro menos capaz da persona. A falha
determina Alto risco; a revisão segue com todas as lentes aplicáveis.
A **auditoria** é tudo acima do piso: achados com nota contra a WCAG 2.2 AA,
com o grau do que você de fato pôde conferir.
Condensado da lista de verificação WCAG do `ux-heuristics` da wondelai (MIT;
ver `../THIRD_PARTY_NOTICES.md`).

## O piso (portão) — os números canônicos

Esta tabela é a referência canônica. Ao mudar um limite, atualize também
suas repetições nos outros arquivos.

| Checagem | Limite | Fonte |
|---|---|---|
| alvo de toque | 44×44 px CSS em superfícies de toque, com espaçamento para que um toque errado não acerte nada | os 44 pt da Apple HIG e o piso da persona; a WCAG 2.2, 2.5.8 (AA), fixa 24×24 px CSS, com exceções, inclusive de espaçamento e de alvo em linha; a 2.5.5 (AAA) fixa 44 |
| contraste do texto | ≥4,5:1 para texto abaixo de 24 px (cerca de 18,7 px em negrito) e ≥3:1 acima disso | WCAG 1.4.3 |
| contraste de componente da interface | 3:1 para as partes que indicam estado ou limite | WCAG 1.4.11 |
| a cor como único portador | nunca | WCAG 1.4.1 |
| texto corrido no celular | 16 px no mínimo; 18 px de preferência para a persona ingênua. Texto corrido = texto necessário à tarefa: frases, rótulos de ação e de campo, status, mensagens de erro, eixos e legendas. Etiquetas de metadados, carimbos de hora e rótulos de abas recebem nota, não portão; abas são a exceção entre os rótulos de ação | piso da persona (a WCAG não fixa tamanho mínimo; a 1.4.4 exige ampliar a 200 %) |
| refluxo | nenhuma rolagem horizontal a 320 px | WCAG 1.4.10 |
| armadilha de teclado | o foco sempre consegue sair | WCAG 2.1.2 |

O alvo de 44 px é um piso da persona, não um piso legal: um produto que
promete servir quem lê com menos capacidade deve a essa pessoa o número da
HIG, e o cartão o cita assim.

**Calcule o contraste; não o estime a olho.** As falhas se escondem no nível
"apagado" (legendas esmaecidas, rótulos secundários feitos para parecer
discretos). Receita, no console do navegador ou num script: para cada canal
c em sRGB 0–1, linear = c ≤ 0.04045 ? c/12.92 : ((c+0.055)/1.055)^2.4;
luminância L = 0.2126 R + 0.7152 G + 0.0722 B; razão = (L_lighter + 0.05) /
(L_darker + 0.05). Obtenha as cores efetivamente compostas do texto e do
fundo. Use `getComputedStyle` para resolver as variáveis CSS e considere
também ancestrais, imagens, gradientes e sobreposições quando existirem.
Componha o alfa antes de calcular.

## Falhas comuns (com nota, acima do piso)

| Problema | Critério | Conserto |
|---|---|---|
| falta texto alternativo ou nome acessível | 1.1.1 para imagens; 4.1.2 para controles | imagem: alt adequado, ou `alt=""` quando decorativa; controle: mecanismo de nomeação apropriado |
| controle só com ícone, sem nome acessível | 4.1.2; 2.5.3 quando houver rótulo visual textual | dê um nome acessível; se houver texto visível no rótulo, inclua-o no nome |
| nenhum indicador de foco visível | 2.4.7 | estilos de `:focus-visible` |
| elemento interativo inalcançável pelo teclado | 2.1.1 | controle nativo, ou `tabindex="0"` com os tratadores |
| campo de formulário sem rótulo | 1.3.1, 3.3.2 | `<label for>` |
| propósito do link indeterminável pelo texto ou pelo contexto programaticamente associado | 2.4.4 | texto ou contexto associado que esclareça o propósito |
| nenhum título de página ou de tela | 2.4.2 | título descritivo |
| mensagem de status não determinável programaticamente | 4.1.3 | semântica apropriada ou região viva quando necessária, para apresentação sem receber foco |
| conteúdo adicional em hover ou foco | 1.4.13; 2.1.1 para operação pelo teclado | que se possa dispensar, que o ponteiro possa pousar sobre ele e que persista, salvo as exceções da 1.4.13; confira separadamente o acesso pelo teclado |
| sentido só pela forma ou pela posição ("o botão da direita") | 1.3.3 | nomeie-o |
| movimento automático por mais de 5 s, paralelo a outro conteúdo, sem controle (salvo se essencial) | 2.2.2 | mecanismo para pausar, parar ou ocultar; confira também `prefers-reduced-motion` |
| mais de 3 flashes por segundo sem atender aos limiares de flash geral e vermelho | 2.3.1 | limite a frequência ou mantenha os flashes abaixo dos limiares previstos no critério |
| idioma não declarado | 3.1.1 | `<html lang>` |

## O que uma captura de tela não diz

Liste estes itens em "não avaliado", a menos que você tenha feito a
checagem; chutá-los é o jeito clássico de uma revisão fabricar confiança.

- **Teclado:** ordem de tabulação, visibilidade do foco, armadilhas. Pede
  uma página viva e um percurso pelo teclado.
- **Leitor de tela:** nomes acessíveis, papéis, estados, anúncios. Pede a
  árvore de acessibilidade (DevTools) ou um leitor de tela.
- **Movimento:** o tratamento de `prefers-reduced-motion`, os controles de
  pausa. Pede o app rodando.
- **Zoom e refluxo:** texto a 200 %, largura de 320 px. Pede um
  redimensionamento.
- **Tempo:** tempos-limite, limites prorrogáveis. Pede o app rodando ou o
  código-fonte.
- **Contraste dos estados dinâmicos:** hover, pressionado, desabilitado.
  Pede os estados renderizados.

Numa página renderizada com DevTools dá para avaliar a maior parte da
tabela; numa imagem estática dá para avaliar o contraste (calcule-o), o
tamanho (se a escala for conhecida), o sentido só pela cor e os rótulos.
Diga em qual das duas situações você estava. Um portão só reprova com
`[Medido]` ou `[Observado]`. Com `[Julgamento]`, registre "medição pendente"
em "Não avaliado"; isso não é falha de portão.

## Ferramentas, quando houver

A cobertura dos analisadores automáticos (axe, Lighthouse, WAVE, Pa11y)
varia por ferramenta, versão, critério e amostra. Eles valem a pena para os
problemas mecânicos; o percurso pelo teclado e a leitura da árvore de
acessibilidade são manuais. A saída de um analisador é `[Medido]` para o que
ele confere; todo o resto mantém o próprio grau.
