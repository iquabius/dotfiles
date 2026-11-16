# Método — portões, células, escalas, conflitos e as regras contra a inflação

## Portões (conferidos antes de qualquer pontuação)

**Universais, sempre ligados:**

1. **Beco sem saída** — a opção deixa a persona sem caminho adiante: sem
   nova tentativa, sem saída, sem próximo passo.
2. **Dano irreversível sem consentimento** — uma cobrança, uma perda, um
   envio, uma atribuição que ela não pode desfazer e não escolheu sabendo.
3. **Piso de acessibilidade** — inutilizável para o membro menos capaz da
   persona: alvos abaixo de 44 px em toque, contraste do texto abaixo de
   4,5:1 (3:1 para texto grande e componentes), cor como único portador,
   texto corrido abaixo de 16 px no celular.

**Portões do domínio, permitidos com disciplina.** Um portão do domínio tem
de ser (a) conferível de modo binário, (b) ligado a um inegociável que o
D disse ou aceitou (regulatório, contratual, central à marca ou
conferível fisicamente, como uma superfície que corta o texto) e (c)
**declarado antes de a pontuação começar**. Um portão proposto depois que as notas existem é inflação de
portões: inventar um desclassificador para matar uma opção de que alguém já
desgosta. Nomeie-a, recuse-a e deixe a preocupação virar uma célula de
severidade máxima contra a opção, onde ela tem de se defender às claras.

A opção que falha num portão sai da matriz com uma linha de evidência. Sem
células, sem porcentagens: pontuar um cadáver lhe empresta uma vida falsa.
A vigente que falha num portão sai das opções recomendáveis, mas fica
como referência das comparações, com a falha na linha dos Portões.

**Becos sem saída mascarados.** Quando uma demonstração ou um interlocutor
roteirizado responde na hora, ninguém vê o estado em que uma pessoa de
verdade ficaria esperando. No passo dos portões, confira o **caminho
humano** (leia o código ou o design atrás do estado que a demonstração
pula); um beco sem saída achado ali é um portão como qualquer outro. Um beco
sem saída notado só depois que as células existem não é promovido a portão
(isso seria inflação): vira a célula de severidade máxima contra aquela
opção, e o artefato diz isso. A mesma regra vale para a `revisao-de-usabilidade`.

**Um defeito que todas as opções têm.** Quando o elemento que falha
pertence a um componente que todas as opções reaproveitam (um cartão
exibido em todos os lugares onde é posto), o portão não distingue entre as
opções, e tirar todas as linhas não deixa nada para decidir. Registre-o como
**precondição do que for entregue**, acima da matriz, com a evidência;
pontue as opções no que difere entre elas. A precondição não é dispensada;
é encaminhada.

**Opções mal especificadas.** Quando uma opção com nome se lê de dois jeitos
(o elemento antigo fica ou sai?), pontue a leitura mais forte, diga a
leitura na linha do enquadramento e ofereça a outra a quem decide como mais
uma opção, se ela for de fato diferente. Nunca pontue um espantalho.

## A persona e a vigente (declaradas no enquadramento)

As opções são julgadas em nome de alguém. Carregue o arquivo da persona da
skill irmã, `revisao-de-usabilidade/references/personas.md`, do diretório
de skills (`~/.agents/skills/` ou `~/.claude/skills/`). Os dois são links
simbólicos para pastas reais separadas, então o `../revisao-de-usabilidade`
a partir do diretório desta skill não chega lá. Se o arquivo não estiver
lá, declare a persona ali mesmo com os mesmos seis campos: nome e
identidade; piso de capacidade; comportamento de leitura; ansiedades; a
tarefa (quem decide a fornece; se não a forneceu, proponha uma e
marque-a); cegueira (a persona lê a frio). Esse arquivo também define os
**lugares** (qual usuário de um produto de vários usuários está olhando);
uma opção que dá uma tela a um lugar e deixa outro sem nenhuma é sinal de
peça faltando para o passo de hibridizar. A persona dá nome à camada
retórica quando ela aparece ("Índice do Novato" para a persona ingênua;
outra persona, outro nome).

**A vigente é a referência.** Identifique o que de fato se entrega hoje
(texto ou código em produção, nunca uma maquete não entregue) e rotule-a uma
vez, do mesmo jeito, em toda parte. Quando a vigente é uma das opções com
nome, ela é a referência da comparação (o *datum* de Pugh, o ponto fixo):
as outras opções são pontuadas como mudanças a partir dela, e um
retrocesso em relação a ela é nomeado como tal. A severidade de cada
célula é absoluta em todas as colunas, a da vigente inclusive; a mudança
a partir dela aparece no veredito par a par. Quando nenhuma opção é a
vigente, acrescente-a mesmo assim como referência, porque não entregar
nada entrega a vigente. Como o
vencedor pode virar com a escolha da referência (Nicholson & Collopy), um
quase empate é conferido de novo contra uma segunda referência antes de ser
anunciado.

## Anatomia de uma célula de evidência (por eixo × opção)

1. **Observação → percepção → consequência.** A violação que se pode
   apontar ("depois da falha, o widget mostra uma tela sem saída"), o que
   ela faz à persona ("ela não consegue terminar a tarefa"), o que se segue
   ("esta opção precisa de uma saída enxertada").
2. **Severidade 0–4** (a escala de Nielsen: 0 não é problema · 1 cosmético
   · 2 menor · 3 maior · 4 catastrófico), qualificada por **frequência**,
   **impacto** e **persistência**. Os fatores vão escritos na célula; um
   dígito sozinho não é evidência.
3. **Grau de evidência:**
   - `[Medido]` — dados instrumentados, tempos, métricas.
   - `[Observado]` — uma sessão real, uma renderização real, uma gravação.
   - `[Julgamento]` — uma decisão heurística de especialista, contestável mas
     apontável.
   - `[Afirmado]` — uma afirmação sem respaldo. Permitida; vai com o rótulo.
4. **Veredito par a par onde der.** "B vence Y em controle do usuário porque
   B sempre mostra uma saída e Y não" pesa mais que uma nota absoluta: em
   julgamentos de comprimento de linhas, o julgamento comparativo foi
   cerca de duas vezes mais confiável que a estimativa de magnitude (Smith
   et al. 1984, via Frey et al. 2009, que tratam a transferência ao
   projeto como hipótese).

Quantifique ou diga que não dá: "4 de 8 testadores desistiram no pagamento"
vence "os usuários se confundem". Uma célula vaga é `[Afirmado]` até que
alguém faça o trabalho. Achados importados de uma
`revisao-de-usabilidade` mantêm os IDs, os graus e as severidades; os de
uma `banca`, cujo cartão não tem ID nem grau e cuja severidade vem do
cartucho, ganham na célula a severidade 0–4 e o grau. A célula cita o
cartão.

`[Afirmado]` na prática: um número com cara de preciso, sem método por
trás, usado para persuadir ("only 15 % of executives say…", tirado de uma
pesquisa de uma frase dentro de um artigo de gestão). Repare
nisso nas apresentações dos outros; rotule nas suas células.

## Honestidade da escala — a divisão

- A **camada de evidência** fala de modo ordinal e comparativo: severidades
  e vereditos par a par. São julgamentos e se vestem como julgamentos.
- A **camada retórica** fala em porcentagens. Elas são inventadas, existem
  para persuadir e tornar a comparação vívida, e a legenda as cobre.

A granularidade é uma troca com dois lados (Nicholson & Collopy 2019):
escalas grosseiras não são automaticamente mais seguras, porque descartam
graus e incerteza que quem pontua pode de fato conhecer. Ajuste a resolução
da camada de evidência ao que se sabe; nunca deixe a falsa precisão da
camada retórica escorrer para baixo.

## Quando os eixos brigam

Dois pilares apontando para lados opostos (o minimalismo manda tirar o
controle, reconhecer em vez de lembrar manda mantê-lo) não são um empate a
tirar na média. Decida conscientemente pelo contexto: **tipo de usuário**,
**criticidade da tarefa**, **reversibilidade da ação**, **frequência do
caminho**. Registre qual fator venceu e por quê; essa frase muitas vezes é a
decisão inteira. Procure primeiro as soluções que atendem aos dois
(desfazer em vez de um diálogo de confirmação; revelação progressiva em vez
de remoção).

## Falibilidade da passada única

Uma matriz de uma passada só tem modos de falha demonstrados: o vencedor
pode virar com a escolha da referência, e acontecem ciclos em que A
vence B, B vence C e C vence A (Nicholson & Collopy 2019). Trate qualquer
passada única como ferramenta de eliminação e discussão, nunca como prova.

- Um **quase empate na evidência** é um sinal, não um resultado: a matriz
  pode estar dizendo "informação insuficiente". Junte evidência,
  acrescente ou hibridize opções. Nunca vá ajustando as notas até aparecer
  um vencedor. Um empate só nas porcentagens não é um quase empate;
  evidência par a par empatada é.
- Rodar de novo com outro conjunto de opções é iteração legítima; rodar de
  novo com outras notas para inverter um veredito é lavagem.

## Quando não usar

- Uma porta de mão dupla reversível, com pouco em jogo → uma escolha rápida
  do D.
- O problema ainda está nebuloso → enquadre primeiro; uma matriz sobre uma
  pergunta mal enquadrada é bobagem confiante.
- Uma decisão cujo critério se mede (preço, capacidade, SLA, prazos
  legais) → não rode a matriz: diga o que se mediria e de onde viriam os
  números, e ofereça a matriz só para a parte que não se mede; este
  instrumento vai enganar ali.
- Só uma opção viável → uma matriz com uma linha viva é decoração.
- Um design só a provar, não opções a comparar → `revisao-de-usabilidade`.
