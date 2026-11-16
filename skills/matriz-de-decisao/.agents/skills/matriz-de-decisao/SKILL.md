---
name: matriz-de-decisao
description: >-
  Resolve uma decisão disputada entre opções com nome (produto, UX,
  texto, design ou outro: o que não se mede) numa matriz que separa
  evidência e retórica: triagem da reversibilidade, hibridização antes
  de pontuar, portões declarados que desclassificam (beco sem saída, dano
  irreversível, piso de acessibilidade), células com violação apontável,
  severidade 0–4 e grau de evidência, vereditos par a par contra a
  vigente, recomendação e, quando a pessoa decide, o registro. A camada
  retórica opcional (porcentagens inventadas, o "Índice do Novato" da
  persona ingênua) sempre leva a legenda. Não serve para decisões medidas
  (preço, capacidade, SLA), um design só (revisao-de-usabilidade),
  escolhas trivialmente reversíveis nem prós e contras sem decisão. Use
  quando pedirem uma matriz de decisão ou um veredito entre alternativas,
  ou quando uma revisao-de-usabilidade ou uma banca achar uma bifurcação
  real e quem decide pedir a arbitragem.
  Também em inglês: "decision-matrix", "Newcomer Index", "which of these
  should we ship".
---

# Matriz de decisão

Arbitre entre opções como o faria um revisor honesto diante de quem vai
conviver com a escolha: diga o que há de errado em cada opção, aponte,
gradue o quanto você tem certeza, compare-as par a par, recomende e então
devolva a decisão. A matriz é um argumento que se contesta célula por
célula, não uma medição.

## Três camadas, nunca misturadas

| Camada | O que guarda | Voz |
|---|---|---|
| **Evidência** | portões, violações apontáveis, severidade 0–4, graus de evidência, vereditos par a par | ordinal e comparativa; sempre exibida |
| **Retórica** | porcentagens inventadas por eixo e um índice agregado, para ganhar adesão | opcional, desligada por padrão; leva o nome da persona; sempre com a legenda |
| **Decisão** | a recomendação (R) e a decisão da pessoa (D) | o D é sempre uma pessoa |

A camada de evidência é a saída padrão. A camada retórica existe porque uma
comparação vívida ganha adesão onde uma tabela de severidades não ganha, e
ela só é honesta porque diz o que é. Nunca deixe a retórica inverter a
evidência: a opção que perde os vereditos par a par não fica com o índice
maior, nem em números nem em pixels.

## Regras firmes

1. **Quem decide detém o D.** Aqui o D é de uma pessoa identificada (o
   RAPID da Bain também admite um grupo com o D); esta skill detém só o
   R, recomenda. Uma recomendação contrariada é o sistema funcionando;
   registre a decisão contrária e siga.
2. **Chamada por quem decide.** Ao notar uma bifurcação real, ofereça a
   matriz uma vez ("quer uma matriz para isso?"); o processo só roda
   quando quem decide pede ou aceita. Uma matriz disparada sem pedido afirma
   que a decisão está em disputa e pressiona o D, o oposto do trabalho dela.
3. **A legenda é obrigatória** onde a camada retórica aparecer, ao lado
   da frase D/R. Legenda: *"As porcentagens são retórica; as violações nas
   células são a evidência."* Frase D/R: *"Isto é uma recomendação (R);
   \<nome\> detém o D."* Um artefato sem porcentagens não precisa de
   legenda.
4. **A voz muda o tom, nunca os fatos.** Neutra por padrão;
   `references/vozes.md`.
5. **Adesão, não consenso.** O critério de fechamento é a adesão à
   escolha do D; tomar o consenso como critério pode ser um obstáculo à
   ação. O pedido explícito do passo 7 é o que busca essa adesão.

## Antes da primeira passada

Leia `references/metodo.md` antes do enquadramento e `references/relatorio.md`
antes de emitir qualquer coisa, inclusive a matriz só de evidência; o modelo
mora lá. Leia `references/vozes.md` só quando pedirem uma voz. O artefato é
escrito na língua de quem decide; os modelos são esqueletos em português, e
os marcadores (`[Medido]`, os nomes dos eixos, os IDs das checagens dos
cartões importados) ficam como estão escritos.

## Processo

0. **Triagem da reversibilidade.** Uma porta de mão dupla com pouco em jogo
   ganha uma escolha rápida do D e nenhuma matriz. A matriz é para portas de
   mão única e escolhas de fato disputadas. Rodá-la numa escolha trivial é
   teatro de processo; diga isso e pare, com a escolha rápida proposta em
   uma linha. A triagem é sua e vai dita no começo; quando o D pediu a
   matriz e você a acha trivial, diga por quê e pergunte antes de parar.
1. **Enquadre.** Se a decisão ou as opções ainda não têm nome, enquadre
   antes de tudo: as restrições reais, separadas dos padrões herdados; ao
   montar o conjunto, prefira a opção que carrega menos suposições. Depois
   nomeie cinco coisas: a decisão, nas palavras de quem decide; as opções,
   como essa pessoa as chama (uma opção mal especificada é pontuada na
   leitura mais forte, e essa leitura é declarada); quem detém o D (se o
   pedido não diz, pergunte; sem resposta, é quem pediu, e o artefato diz
   isso); a **vigente** (o que se entrega hoje, a referência contra a qual
   as outras são pontuadas; sem código nem texto em produção para ler,
   pergunte, e sem resposta marque a suposição); e a **persona**, em nome
   de quem as opções são julgadas. Para a persona, carregue
   `revisao-de-usabilidade/references/personas.md` do diretório de skills
   (`~/.agents/skills/` ou `~/.claude/skills/`), ou declare os seis campos
   no próprio texto (`references/metodo.md`); a persona padrão é a
   ingênua desse arquivo. Quem decide dá a tarefa da persona; uma tarefa
   que uma revisão anterior já fixou se reaproveita e se cita; se não há
   nenhuma, proponha uma e marque-a.
2. **Hibridize antes de pontuar.** Pergunte a si mesmo se duas opções se
   juntam numa melhor, e se uma peça que falta (um lugar a que ninguém deu
   uma tela, um estado que ninguém tratou) aponta para uma opção que
   ninguém nomeou. A opção que você achar entra na matriz anunciada como
   sua, para o D aceitar ou tirar. A geração de opções pesa mais que o
   resto do procedimento: nenhum refinamento na pontuação compensa uma
   opção melhor que ficou de fora. Pontue só um conjunto explorado com
   honestidade. Alternativas renderizadas (uma "oficina" de vários
   candidatos completos a partir de um mesmo pedido) são o jeito mais
   barato de explorá-lo, e são opcionais.
3. **Portões, declarados antes de qualquer nota.** Os três portões
   universais (beco sem saída · dano irreversível sem consentimento · piso
   de acessibilidade), mais qualquer portão do domínio declarado agora.
   Pergunte ao D pelos inegociáveis antes de pontuar; um que você propõe
   vai marcado como proposto e só vale com o sim dele. A opção que falha
   num portão sai com uma linha de evidência; não ganha células nem
   porcentagem (a vigente que falha fica como referência das comparações,
   fora das recomendáveis). Um defeito que todas as opções têm é uma
   precondição do que for entregue, não um portão. Um portão proposto
   depois que as notas existem é inflação de portões: nomeie-a, recuse-a e
   deixe a preocupação virar uma célula de severidade máxima.
4. **Células de evidência.** Por eixo × opção: uma violação que se pode
   apontar, o custo dela para a persona, uma severidade 0–4 com frequência,
   impacto e persistência, um grau de evidência e um veredito par a par
   onde der. Achados de uma revisao-de-usabilidade ou de uma banca entram
   aqui como células.
5. **Veredito.** Par a par primeiro: cada opção contra a referência e,
   entre as outras, ao menos o par mais disputado, com o eixo em que uma
   vence a outra e por quê. Quando os eixos brigam, nomeie o fator de
   contexto que decidiu (tipo de usuário, criticidade da tarefa,
   reversibilidade, frequência do caminho). Um quase empate na evidência
   pode querer dizer informação insuficiente: confira contra uma segunda
   referência, junte mais evidência ou acrescente opções; nunca repontue
   para forçar um vencedor. Sem evidência nova à mão, o R diz que a
   evidência não decide, o que se mediria, e propõe a vigente até lá.
6. **Camada retórica (só se pedirem).** Porcentagens por eixo e o índice
   agregado, com o nome da persona e a legenda visível, exibidos depois da
   evidência e mais discretos que ela. Regras em `references/relatorio.md`.
7. **Recomende e devolva.** Termine com o R, com o conserto mais
   importante de que a vencedora ainda precisa (se houver) e com o pedido
   explícito ao D. Nunca uma reflexão abstrata.
8. **Ofereça um registro.** Depois que o D decidir, na resposta seguinte à
   decisão, ofereça o registro da decisão (o modelo do
   `references/relatorio.md`), para o log do projeto. Ofereça; nunca o escreva sem pedido. Sem convenção de log no
   projeto, devolva a linha pronta.

## Eixos

- **Decisão de UX** → as heurísticas de usabilidade de Nielsen; as quatro
  primeiras como pilares padrão: visibilidade do status do sistema ·
  correspondência com o mundo real · controle e liberdade do usuário ·
  consistência e padrões. Os pilares são o mínimo: um eixo que o domínio
  pede (privacidade, por exemplo) entra com uma linha de justificativa.
- **Decisão de notação, DX ou ferramenta** → as Dimensões Cognitivas das
  Notações (viscosidade, visibilidade, expressividade de papel,
  proximidade de mapeamento, …).
- **Qualquer outro domínio** → declare os eixos e justifique-os no
  artefato, uma linha cada.

## Composição

A `revisao-de-usabilidade` prova um design e emite cartões; a `banca` prova
um texto e emite cartões; esta skill arbitra **entre** opções e consome
esses cartões como células de evidência. A `revisao-rigorosa` julga código
e planos e nunca entra na matriz.

## Jurisprudência (três disparos, anonimizados; cada um mostra um passo)

- **O híbrido venceu os dois pais** (passo 2). O painel de nova tentativa
  vencedor não estava no conjunto original. Era a junção de duas opções
  concorrentes e venceu cada uma delas em todos os eixos. Nada na
  pontuação poderia tê-lo achado.
- **Um beco sem saída pontuado com 41 % em vez de barrado** (passo 3). Uma
  tela de erro que deixava a persona encalhada com o id, já usado, de uma
  transação "perdeu" nos pontos (uma nota em porcentagem, que esta skill
  só admite na camada retórica). Ela nunca deveria ter tido coluna: a nota
  baixa deixou um cadáver entrar na matriz e fez a comparação parecer mais
  apertada do que era.
- **O D trocou dois botões por um** (passo 7). A matriz defendia manter
  "tentar de novo" e "recomeçar"; quem decidiu entregou um só. A decisão
  contrária foi entregue, registrada, e o produto fez bem em ter um D.

## Nunca

- Nunca mostre uma porcentagem inventada sem a legenda.
- Nunca deixe os números do índice vazarem para documentos, métricas ou
  apresentações como se fossem medidos.
- Nunca rode a matriz numa escolha trivialmente reversível.
- Nunca aplique um portão inventado depois que a pontuação começou.
- Nunca repontue um quase empate até sair um vencedor.
- Nunca deixe a camada retórica, em números ou no layout, inverter a ordem
  da camada de evidência.
- Nunca decida: o D é uma pessoa identificada, e um R que decide tomou um
  papel que nunca lhe deram.

## Fontes nomeadas

Conferidas em 2026-10-31. A data da conferência vai com a citação, para
que uma reformulação posterior da fonte não falseie a citação depois do
fato (política herdada da skill de origem); confira de novo antes de
citar externamente.

- Papéis de decisão e adesão acima do consenso — Rogers & Blenko, "Who Has
  the D?", Harvard Business Review, 2006 (o RAPID é o modelo da Bain).
- Portas de mão única e de mão dupla — Bezos, carta aos acionistas da
  Amazon, 2015.
- Heurísticas de usabilidade e a escala de severidade 0–4 — Nielsen
  (Nielsen Norman Group).
- Dimensões Cognitivas das Notações — Green & Petre (1996).
- A crítica da falsa precisão da pontuação ponderada — Pugh & Smith
  (1976); a matriz de comparação grosseira e a referência (datum) — Pugh
  (1981, 1990); avaliadas em Frey et al., *Research in Engineering
  Design*, 2009, que também é a fonte da dominância da geração de opções e
  da ideia de que o par a par vence a magnitude (via Smith et al., 1984,
  medido em julgamentos perceptuais; a transferência ao projeto é hipótese
  do artigo).
- Modos de falha da matriz de uma passada só (sensibilidade à referência,
  ciclos de Condorcet) — Nicholson & Collopy, ICED 2019.
- "The highest score will not necessarily be the one to choose" — guia de
  matriz de decisão da ASQ; Tague, *The Quality Toolbox*.

## Referências

- `references/metodo.md` — portões, becos sem saída mascarados,
  precondições comuns, a persona e a referência, a célula de evidência, a
  honestidade da escala, a resolução de conflitos, a falibilidade da
  passada única, quando não usar.
- `references/relatorio.md` — a matriz em texto, a legenda e a frase D/R,
  as regras da camada retórica, a escada de densidade, a lista para
  conferir a honestidade da exibição, o registro da decisão.
- `references/vozes.md` — o contrato das vozes (neutra, Linus,
  carnavalesca).
