# Relatório — a matriz, a legenda, a camada retórica, o registro

## Artefato padrão: a matriz em texto (só a camada de evidência)

Para colar, autossuficiente, escrita na língua de quem decide (o modelo
abaixo é um esqueleto em português; os marcadores `[Medido]` … e os nomes
dos eixos ficam como estão escritos, para que os artefatos se comparem entre
línguas):

```
**Decisão:** <uma linha, nas palavras de quem decide — o que se decide e quem detém o D>
**Persona:** <nome>, tarefa "<…>"
**Portões:** <opções desclassificadas, uma linha de evidência cada — ou "todas as opções passam">

| Eixo | Opção A | Opção B |
|---|---|---|
| Visibilidade do status do sistema | [Observado] nenhum sinal de progresso depois de enviar (sev 3: toda vez, impacto alto, persiste) | [Julgamento] status visível a cada passo (sev 0: nenhuma violação) |
| Controle e liberdade do usuário | … | … |

**Par a par:** <A contra B em cada eixo em que diferem, com o motivo>
**Fator de contexto decisivo:** <tipo de usuário | criticidade | reversibilidade | frequência — qual, e por quê>
**Recomendação (R):** <a opção, e o conserto mais importante de que ela ainda precisa, se houver>
Isto é uma recomendação (R); <nome> detém o D.
```

Regras:

- Repita as palavras de quem decide para a decisão e para as opções ("o
  painel de nova tentativa", não "interface de remediação do estado de
  falha").
- Toda célula leva o seu fragmento (grau + violação apontável + severidade
  com os fatores). Sem fragmento, sem célula.
- Opções desclassificadas aparecem só na linha dos Portões; sem coluna. Uma
  precondição comum a todas as opções (metodo.md) aparece como uma linha
  acima da matriz.
- Uma vigente por disparo, rotulada "Vigente (referência)": diga o que de
  fato se entrega hoje, uma vez, e rotule-a do mesmo jeito em toda parte.
  A frase D/R vai sempre no rodapé, salvo no degrau Usuário final.
- As citações remetem ao registro em que foram conferidas (um diário
  de desenvolvimento, um registro de decisão), nunca a um canal privado,
  porque quem lê não recupera uma exportação de conversa ou de reunião, e
  nomeá-la pode expor pessoas que não aceitaram ser citadas.

## A camada retórica (só quando quem decide pede)

Porcentagens por eixo e um índice agregado, **com o nome da persona
carregada** — "Índice do Novato" (🔰) quando a persona ingênua está
carregada; outra persona lhe dá outro nome e outro glifo, declarados no
enquadramento. São inventadas. O trabalho delas é ganhar adesão. Cada
número vai de 0 % a 100 %, maior quer dizer melhor para a persona, e há
um por opção em cada eixo, mais um índice agregado por opção. Em texto,
elas vêm numa tabela própria, depois da matriz de evidência:

```
**Índice do Novato** (retórico; não derivado destas células)

| Eixo | Opção A | Opção B |
|---|---|---|
| Visibilidade do status do sistema | 35 % — sem sinal de progresso | 80 % — status a cada passo |

**Índice agregado:** Opção A 🔰 38 % · Opção B 🔰 76 %
*As porcentagens são retórica; as violações nas células são a evidência.*
Isto é uma recomendação (R); <nome> detém o D.
```

Regras que as mantêm honestas:

- **A legenda aparece sempre com elas, ao lado da frase D/R:** *"As
  porcentagens são retórica; as violações nas células são a evidência."*
  Ela é parte do artefato, não uma nota de rodapé a cortar quando falta
  espaço. Num artefato noutra língua, a legenda é traduzida com
  fidelidade (o sentido literal, as palavras na língua de quem decide);
  "literal" prende a afirmação, não o português.
- **Uma porcentagem nunca aparece sem o seu fragmento.** A densidade pode
  encurtar o fragmento a uma oração apontável; nunca deixa um número órfão.
- **A ordem segue a evidência.** A opção que perde os vereditos par a par
  não fica com o índice maior. As porcentagens amplificam a ordem da
  evidência; nunca a contradizem.
- **Exibidas depois da evidência e mais discretas que ela.** As violações
  nas células se leem primeiro; o índice fica rebaixado, nunca em tamanho
  de título, nunca num banner.
- **Um glifo, um rótulo.** O glifo da persona aparece ao lado de cada
  número do índice agregado, um por número, e em nenhum outro lugar: não
  nas células por eixo, nunca empilhado, escalado ou colorido para
  carregar magnitude.
  Um glifo que codifica um valor encena uma medição que o número não tem.
- **Sem fingimento aritmético.** Por padrão, os números são inventados na
  ordem da evidência e levam a nota "retórico; não derivado destas
  células"; se você os derivar de uma fórmula, mostre a fórmula.

## Escada de densidade (uma decisão, remodelada para um público, a pedido)

A mesma decisão e a mesma evidência, remodeladas e não só restilizadas:

- **Engenharia** — a versão contestável: todas as opções, todos os eixos,
  todas as células por inteiro; destaques par a par com um piso (o par
  mais disputado sempre, mais todo par vizinho cuja ordem no índice
  discorde do padrão das células); a vigente como referência; a linha dos
  portões; o protocolo do quase empate; o espaço do estado da decisão
  (antes do D: o pedido; depois do D: o registro; nunca os dois); a frase
  D/R no rodapé, e, com a camada retórica ligada, a legenda e a frase D/R
  também no cabeçalho.
- **Quem decide** — o resumo para decidir: veredito no começo e no fim; o
  pedido fixado (ação, prazo, saídas); a matriz enxugada (a vencedora, os
  quase empates genuínos, a vigente); o fator de contexto decisivo
  defendido em dois parágrafos; os graus presentes em cada célula ou numa
  única linha geral que seja literalmente verdadeira.
- **Usuário final** — o resultado entregue, depois da decisão: o design
  ou o texto escolhido, literal, antes e depois, na voz da própria marca,
  **sem nada da maquinaria da matriz**: sem porcentagens, sem severidades,
  sem graus, sem nomes de eixos ou de opções, sem legenda. Uma única
  porcentagem ali faz dele uma exibição da matriz, e a legenda passa a
  valer; apague o número em vez disso.

Um pedido, um degrau da escada, um artefato; nunca desdobre sem pedido.
Sem pedido de degrau, vale o artefato padrão do começo deste arquivo.
A engenharia manda nos fatos; se dois degraus discordam, vale a engenharia.

## Honestidade da exibição (lista a conferir antes de entregar qualquer exibição)

Vale para o artefato renderizado (HTML, imagem); no texto colável, valem
só os itens que se aplicam a texto.

- [ ] A evidência domina visualmente; as violações se leem primeiro.
- [ ] Toda porcentagem mais discreta que a evidência que enfeita; nenhuma
      em tamanho de título.
- [ ] Uma cor de destaque; hierarquia por peso e tamanho, não por matiz;
      nenhuma rampa de magnitude por matiz sobre qualquer camada (uma rampa
      de matiz sobre as porcentagens, ou vermelho-amarelo-verde sobre as
      severidades, encena uma medição que os números não têm).
- [ ] Nenhum emoji ou glifo codifica um valor, pelo mesmo motivo.
- [ ] Contraste calculado, não no olho: ≥4,5:1 para texto abaixo de 24 px
      (cerca de 18,7 px em negrito) e ≥3:1 acima disso (WCAG 1.4.3),
      inclusive no nível "apagado"; nenhum rótulo de dado abaixo de 11 px.
- [ ] Durável e autossuficiente: marcação estática ou uma alternativa sem
      JS; dados de uma fonte só; nada carregado de fora.

Esta é uma conferência do artefato, não um portão das opções: falhar nela
impede a entrega até a exibição ser consertada; nunca desclassifica uma
opção. Conserte o layout, nunca a evidência. Gráficos ou infográficos da
matriz só se fazem a pedido explícito (uma matriz em discussão se altera,
e uma imagem velha sobrevive à correção), mantêm a legenda dentro da imagem,
preferem um layout de comparação e voltam com o código-fonte junto, para
que a próxima revisão os gere de novo em vez de redesenhá-los.

Os elementos da marca (fonte, cor de destaque única, fundo, cor do texto,
logo) vêm do produto; nunca se leva um padrão de uma marca para outra.

## O registro da decisão (oferecido depois que o D decide)

```
<data> — <decisão, nas palavras da equipe>. D: <quem decidiu>.
Base: <caminho ou título do artefato>. Fator decisivo: <…>. Alterações do D: <nenhuma | o que o D mudou em relação ao R>.
```

Ofereça-o uma vez, na convenção de log do projeto. Nunca o escreva sem
pedido.
