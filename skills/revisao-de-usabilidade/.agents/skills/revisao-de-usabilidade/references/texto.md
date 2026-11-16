# Texto — a lente que lê em voz alta

O texto do produto está preso à verdade: um rótulo, uma linha de status, um
botão, uma afirmação sobre uma espera comprometem o produto com alguma
coisa, e a persona o cobra por isso. Esta lente lê o texto a frio, como a
persona, e relata cada ponto em que ela empaca, chuta ou acha duas leituras.
O texto longo ou disputado sai desta lente para a oficina da `banca`
(cartucho no fim).

## O protocolo da leitura em voz alta

Leia o texto **em voz alta como a persona** (`personas.md`): a frio, sem
explicação da tela, sem histórico da sessão, sem roadmap. Depois responda às perguntas
dela, nas palavras dela. Cada pergunta que o texto deixa sem resposta é uma
violação apontável da visibilidade do status do sistema (Nielsen 1) ou da
recuperação de erros (Nielsen 9); uma pergunta respondida só por uma cadeia
de inferências é a violação mais fraca, e o cartão nomeia a inferência que o
texto exige.

**Texto de status e de espera: as quatro perguntas.**

1. **SEGURO** — a minha coisa está segura agora? (Marque N/A explicitamente
   quando nada está em jogo, e dê nota às outras três.)
2. **ESTADO** — o que está acontecendo, e mais ou menos por quanto tempo?
3. **LIVRE** — posso sair? Tenho de fazer alguma coisa?
4. **AVISO** — vão me avisar quando terminar ou quando algo mudar?

**Texto de confirmação, de formulário e de ação: as quatro perguntas.**

1. **FAZ** — o que exatamente acontece se eu tocar nisto, e com quem? (O
   efeito, sem eufemismo; a contraparte nomeada.)
2. **CUSTA** — o que isto gasta, compartilha ou compromete, e posso voltar
   atrás?
3. **PRECISA** — o que preciso ter em mãos? Para campos sensíveis ou não
   óbvios, por que esse campo existe?
4. **SAIDA** — como desisto, corrijo um erro ou peço ajuda se falhar?

Procedência: as quatro de status foram calibradas em usos reais (um painel
de textos de espera em 2026-07); as quatro de ação saíram delas em
2026-07-18 e foram usadas pela primeira vez num app multiusuário em 2026-09.
As duas são instrumentos `[Julgamento]`; ainda há poucos casos para as
quatro de ação, então registre em cartão cada empacada contra elas, para o
conjunto se calibrar.

**Mensagens de erro, inclusive de formulário:** aplique Nielsen 9: o que
houve, por quê e o que faço agora? Não aplique a elas os conjuntos de
status ou de ação.

Nunca troque os conjuntos de perguntas: as quatro da espera num diálogo de
confirmação, ou as quatro de ação numa linha de status, não é cobertura. Uma
pergunta composta respondida pela metade conta como o ramo que falta,
nomeado no cartão: nunca passa de graça, nunca conta duas vezes.

**Empacar, chutar, bifurcar.** Operando o texto a frio, cada ponto em que
quem lê empaca, chuta ou acha duas leituras defensáveis é um achado
(`LEITURA-EMPACA`). O texto que *descreve* quando a pessoa precisa de uma
*instrução* é `ERRO-SEM-PROXIMO-PASSO` (Nielsen 9), com severidade de
partida 2–3; se faltam nova tentativa, saída e próximo passo juntos, use o
portão `BECO-SEM-SAIDA`. Uma linha de status que afirma algo falso
("X recusou" quando foi ela quem recusou) é `STATUS-FALSO`, pior que o
silêncio. **Armadilha do jargão:** palavras de mecanismo e de infraestrutura
("sincronizar", "finalizar", "nos bastidores", nomes de protocolo) são
marcadas para conferir se a persona as entende. Saber se a casa proíbe
nomear mecanismos é outra regra, de registro.

**Dê o grau com honestidade.** Um veredito da leitura em voz alta é
`[Julgamento]`: avaliação de usabilidade de baixo custo (discount usability)
por um especialista no lugar do usuário. Ele só vira `[Observado]` quando
uma sessão de um usuário real o sustenta. Nunca faça a empacada da persona
passar por dado de usuário.

## Calibrar a afirmação — quando o texto diz um número

Uma espera, um tamanho, uma contagem, um prazo. A pergunta não é "o número
está certo?", mas "com o que sabemos, que degrau da escada das afirmações é
honesto?"

| Degrau | Forma | Desmentido por |
|---|---|---|
| R0 | silêncio ("…em andamento nos bastidores") | nada |
| R1 | linguagem de paciência ("isto pode levar um tempinho") | nada, na prática |
| R2 | limite suavizado ("até uns 20 minutos") | qualquer resultado acima do limite |
| R3 | ponto com ressalva ("pode levar 20 minutos") | formalmente nada; pragmaticamente, um estouro |
| R4 | limite firme ou ponto seco ("leva 20 minutos", "5 minutos ou menos") | ponto exato: qualquer diferença; limite superior: apenas resultado acima do teto |

As regras que decidem o degrau:

- **O suavizador separa o R2 do R4.** "Até 15 minutos" é R4; "até uns 15
  minutos" é R2.
- **Um número com ressalva se lê como ponto.** "Pode levar 20 minutos"
  chega como expectativa de 20. Julgue o R3 como um R4 com álibi.
  "Normalmente N" expressa uma expectativa de frequência não especificada;
  só afirme mediana quando essa estatística tiver sido definida e medida.
- **Uma quantidade vaga com unidade não é linguagem de paciência.** "Uns
  minutos", "uns dois dias" é uma afirmação em forma de ponto no lado
  rápido; ela quebra para cima toda vez que a realidade demora. Julgue-a
  como R4, a menos que o valor cubra a cauda.
- **Um intervalo de dois lados compromete o produto no limite de cima.**
  "3 a 5 dias úteis" se avalia pelo 5; um intervalo seco é de grau R4, um
  com ressalva ("uns 3 a 5 dias") é R2. Um piso explícito ("pelo menos 10
  minutos") compromete para baixo, a direção livre: risco baixo, a menos que
  venha com um teto.
- **Os estouros quebram a confiança; as sobras saem de graça** (Maister, the
  psychology of waiting lines; citado como `[Julgamento]`). Por isso um
  limite tem de cobrir a cauda, não o típico. Dar a mediana como teto traz
  de volta a promessa curta demais.
- **As pistas de conclusão sobem degraus às escondidas.** "Quase pronto",
  "terminando" endurecem a expectativa sem número; registre-as no degrau que
  a iminência delas implica.
- **O degrau não pode passar da evidência.** O R3 e o R4 pedem conhecimento
  `[Medido]` ou `[Observado]` da distribuição, mediana e cauda. O
  `[Julgamento]` sustenta no máximo um R2 com limite generoso. O `[Afirmado]`
  sustenta um R1, ou um R2 com folga bem além do afirmado. O chute da equipe
  de suporte ou a estimativa da engenharia sem dados é `[Afirmado]`; a
  palavra "engenharia" não contrabandeia um chute escada acima.
- **Nem ficar aquém dela.** A vagueza sobre uma distribuição medida é
  esconder, não calibrar: também é uma violação com nota.
- **Dever de âncora.** Cair para o silêncio só é honesto quando outra coisa
  carrega a âncora: um e-mail de conclusão, um indicador de progresso, uma
  pista de quando voltar. "Um tempinho" sozinho é abandono vestido de
  honestidade; nomeie o elemento que carrega o dever, ou o que falta
  (`SEM-ANCORA`).
- **Nunca vago com dinheiro.** Tarifas, preços, valores devidos: a precisão
  é a honestidade. Números contratuais ou legais são decisão do jurídico,
  não desta lente.

Forma da violação para o cartão: *"o degrau Rn da afirmação passa do grau de
evidência [X] do número"* (`AFIRMACAO-ALEM-DA-EVIDENCIA`). Severidades de
partida: um degrau além da evidência ≈ 2–3; uma afirmação de ponto sobre
sustentação `[Afirmado]` ≈ 3–4; R1 com ansiedade alta e sem âncora ≈ 1–2.
Frequência, impacto e persistência fecham o número.

Higiene de todo número entregue: ele mora numa constante só e é interpolado
em todo lugar; o grau de evidência viaja com ele; quando o fato por trás
muda, o degrau se decide de novo, e não só se troca o número.

## Pessoa, registro e um termo por conceito

O revisor confere o texto **contra o registro que a casa declarou**; nunca
inventa o estilo da casa. Carregue o registro no passo 0 quando o produto
tiver um (um documento de vocabulário, uma voz de marca, o glossário de um
documento de design); quando não houver um declarado, revise só a clareza e
diga que a lente de registro ficou inerte.

- **A pessoa gramatical é uma decisão de registro; o achado é a deriva.**
  Decida quem fala em cada elemento e confira se a superfície se mantém
  nisso. Uma escolha comum da casa: a tela fala na primeira pessoa do seu
  usuário ("minhas tarefas", "puxei 7 de 15") e quem fala *com* o usuário
  diz "você" (o narrador de um tour, a oferta de outra pessoa, uma
  legenda). Misturar numa mesma superfície é `PESSOA-VARIA`; o conserto
  nomeia quem fala em cada elemento.
- **Um termo por conceito, em todo lugar** (Nielsen 2 e 4). Dois nomes
  para a mesma coisa, ou um apelido ao lado do termo, é `TERMO-VARIA`. Um
  verbo cujo registro social contradiz o declarado é o mesmo achado no nível
  do registro (precedente: "delegar", verbo que atribui tarefa, num produto
  de registro declarado de ajuda mútua; o cartão cita o documento de
  registro, e não o gosto do revisor).
- **Fato neutro, não recompensa nem culpa.** Um status dito como elogio
  ("tem folga") convida a manipulá-lo; o mesmo fato dito de modo neutro
  ("abaixo da parte justa") não convida (`ELOGIO-EM-VEZ-DE-FATO`). Uma caixa
  de aviso e um ícone de alarme em volta de uma mensagem que o registro quer
  sem culpa são o mesmo achado pelo lado visual.
- **Fale na unidade da tela.** Se a tela conta em semanas, um sinal em
  contagens brutas ("pulou 8×") obriga a converter; "não feito há ~4
  semanas", não. Um rótulo responde "quando" ou "quanto" sem conversão
  (`ROTULO-FAZ-CONVERTER`).

## Fonte única da verdade na tela

Um número mora num lugar só, o de mais autoridade (em geral a manchete ou o
veredito); os demais elementos ecoam a **direção** dele, não o valor. Dois
elementos mostrando a mesma quantidade calculada de dois jeitos (uma
manchete dizendo 47 % e a legenda de um gráfico dizendo 67 % sobre outra
janela) é `NUMERO-DUPLICADO`, a forma na tela do mau cheiro de código "duas
fontes da verdade". O mesmo item renderizado duas vezes numa tela (uma
tarefa na lista e de novo num cartão abaixo) é `ITEM-DUPLICADO`.
Relacionado: `HORIZONTES-MISTURADOS` em `exibicao-de-dados.md`.

## Caber no layout — o portão de domínio para texto numa caixa

O texto que está certo num documento e é truncado no componente está errado.
Este é o modelo de portão de domínio, declarado no passo 1, antes de as
lentes rodarem. Declare: a **capacidade medida** da superfície em pontos de
código, a partir de uma renderização real (nunca suposta; valide o contador
numa cadeia com um emoji e um travessão, porque `wc -m` pode contar bytes),
uma **tabela de comprimentos dos campos variáveis** (curto / típico / cauda
longa, com exemplos nomeados e o corte entre o típico e a cauda longa) e o
**comportamento de truncamento** (reticências, corte, quebra que empurra a
ação para baixo). Estourar nos comprimentos típicos reprova o portão
(`TEXTO-TRANSBORDA`); estourar só na cauda longa é um achado com nota,
pesado pela frequência real da cauda. Sem medição, o risco de não caber fica
registrado como medição pendente, nunca como portão e nunca descartado.

## O cartucho da banca para textos de produto

Quando o texto é longo, de várias vozes ou já contestado, esta lente para
nos cartões e entrega o artefato à oficina da `banca`. As sete declarações
de cartucho que a `banca` exige, para textos de produto:

1. **Polaridade da licença** — preso à verdade: o texto não pode mentir; a
   metáfora mantém a licença palavra por palavra ("preparando seus
   resultados" tem licença, "20 minutos" está preso). Toda afirmação
   quantitativa passa pela escada acima.
2. **Elenco de lentes** — lentes de função: semântica e compromisso
   (acarretamento, pressuposição, coerência entre título e corpo; para no
   sentido), prosa (as regras de estilo da casa; para no conjunto de
   regras), registro (as regras declaradas da casa; recebe a intenção;
   inerte sem regras declaradas). Persona: o ingênuo da leitura em voz alta,
   acima, sempre cego. Lentes de evidência: a verificação byte a byte do
   texto contra a fonte, o contador de pontos de código, os dados de tempo
   para os graus da escada.
3. **Escada de altitude** — arquitetura das afirmações → coerência da
   tela → frase → palavra → formatação.
4. **Literatura de efeitos** — a psicologia da espera (Maister; Taylor 1994
   sobre atribuir a causa de uma demora), citada como `[Julgamento]` até ser
   verificada de novo; o resto entra como heurística da casa, rotulada.
5. **Escala de severidade e verbos de cirurgia** — os cartões usam
   **Impeditivo** (bloqueia a rodada da oficina ou entrega uma afirmação
   falsa) · **Lacuna** (falta uma instrução ou um recurso necessário) ·
   **Inconsistência** (duas orações em conflito) · **Vago** (presente, mas
   ambíguo) · **Sugestão**. Verbos: enxugar / expandir / reenquadrar /
   reestruturar, mais dividir-degrau · rerrotular · refazer-citação ·
   marcar-não-verificado · remeter-ao-cânone · acrescentar-exemplo.
6. **Desenho do chamariz** — um texto genérico de UX writing com três chavões
   ("seja claro e honesto", "use linguagem simples", "defina as expectativas
   cedo") fechado por uma isca refeita a partir de uma mecânica real do
   artefato em revisão; nunca reuse um chamariz anterior ao pé da letra.
7. **Convenções do relatório** — os cartões no chat, na língua do usuário; o
   livro-razão e o relato no log do projeto.

A oficina prova um texto; os cartões desta lente a semeiam; uma bifurcação
entre textos candidatos segue para a `matriz-de-decisao`.
