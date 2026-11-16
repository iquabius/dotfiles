# Exibição de dados — números e gráficos na tela

Um gráfico é texto noutra notação: faz uma afirmação, e a persona o cobra
por ela. Esta lente confere se o tipo de gráfico combina com os dados, se os
números da tela concordam entre si e se a exibição não contrabandeia um
julgamento que os dados não trazem.

## A forma dos dados decide o gráfico

| Os dados são… | Mostre como… | Evite |
|---|---|---|
| uma quantidade ao longo do tempo (tendência) | uma linha, ou uma área quando o preenchimento quer dizer algo | barras para muitos períodos; uma pizza de períodos |
| uma comparação entre poucas categorias | barras horizontais num eixo só, ordenadas ou numa ordem com sentido | ângulos (pizza, rosca): as pessoas comparam comprimentos muito melhor que ângulos |
| uma parte de um todo, num momento | uma barra empilhada, ou o próprio número com o total ("7 de 15") | uma rosca quando a tendência é o ponto: ela esconde a direção |
| uma distância até uma meta | uma barra divergente em volta da linha da meta | uma barra crua que torna a meta invisível |
| um conjunto pequeno e contável | um pictograma ou uma fileira de marcas contáveis | uma porcentagem de uma contagem pequena ("33 %" de 3) |
| uma distribuição | um histograma ou um diagrama de caixa | uma linha que sugere continuidade |
| uma relação entre duas quantidades | uma dispersão | uma linha de eixo duplo, que convida a uma falsa correlação |

Um tipo de gráfico que briga com a forma dos dados é `GRAFICO-ERRADO`. O
conserto nomeia a forma e o tipo que combina com ela.

## Regras de honestidade para números na tela

- **Barras partem do zero.** Uma base truncada exige aviso
  (`BASE-TRUNCADA`); `FALSO-ZERO` trata só de período ausente.
- **Lacuna é lacuna.** Um período sem dados aparece como lacuna ou como um
  "sem dados" explícito, nunca como zero. Um falso zero é uma afirmação que
  os dados não fizeram (`FALSO-ZERO`).
- **Um horizonte de tempo por tela, ou diga a natureza.** Dois tipos de
  número convivem nas telas de status: os **agregados de janela** ("últimas
  4 semanas: 7 de 15") e os **fatos de sequência** ("pulou 3 vezes
  seguidas", "não feito há ~4 semanas"). Forçar um no outro corrompe o
  sinal: o fato de sequência posto numa janela perde o padrão crônico; o
  agregado lido como um momento engana. Ou a tela inteira usa uma janela só,
  ou todo número que não é da janela diz o que é (`HORIZONTES-MISTURADOS`).
  "4 semanas" e "~5 semanas" na mesma tela, querendo dizer coisas
  diferentes, é o caso canônico.
- **A manchete é dona do número; o gráfico ecoa a direção.** Quando uma
  manchete diz um valor, o gráfico abaixo dela mostra a trajetória: cor
  neutra, pontos uniformes, nenhum número rival na legenda que quem lê
  precise conciliar com a manchete (`NUMERO-DUPLICADO`).
- **Comprimentos num eixo comum, não ângulos.** Para "quem carrega mais",
  uma barra por pessoa num eixo só vale mais que fatias.
- **Nenhum placar quando o assunto é justiça.** A regra vale para telas
  que medem divisão justa de trabalho entre pessoas; painéis de desempenho
  comercial ficam fora. Ordenar pessoas por carga ou por contribuição se lê
  como competição e dispara a aversão à desigualdade; transforma um
  instrumento de justiça num placar. Mostre cada pessoa contra a parte
  justa, numa ordem fixa, com quem olha a tela em primeiro lugar
  (`RANKING-EM-JUSTICA`).
- **Uma marca na meta.** Quando alguém está exatamente na linha justa,
  mostre-o (um toquinho, um traço); "exatamente justo" é informação, e uma
  barra de comprimento zero a esconde.
- **A cor nunca carrega o único sentido.** Um ponto mais um rótulo, uma
  hachura, uma posição; o gráfico tem de sobreviver em tons de cinza
  (`SO-COR`, um portão).
- **Rótulos dos eixos nas palavras da tela.** "semana passada", "há 2
  semanas", não "−1", "−2".

## O que a revisão relata

Para cada gráfico: a forma dos dados como você a leu, o tipo usado, se
combinam, e cada número da tela com que o gráfico tem de concordar. Dê o
grau `[Observado]` quando você leu o gráfico numa renderização real;
numa imagem estática com eixo legível, use `[Julgamento]`. Use `[Medido]`
quando conferiu os valores contra os dados de origem. Um gráfico que você
não pôde ler (sem dados, uma imagem estática sem eixo) vai para "não
avaliado".
