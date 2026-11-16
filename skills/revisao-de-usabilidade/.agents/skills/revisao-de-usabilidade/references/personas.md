# Personas — em nome de quem a revisão é feita

Um design nunca é "usável"; é usável *por alguém fazendo alguma coisa*. A
persona fixa o alguém. Este arquivo é compartilhado com a
`matriz-de-decisao`, que o lê do diretório de skills
(`~/.agents/skills/` ou `~/.claude/skills/`), para que os dois instrumentos
julguem em nome do mesmo leitor.

## O contrato da persona

A declaração de uma persona leva seis campos. Uma revisão pode carregar a
padrão abaixo, carregar uma persona com nome do projeto (um documento de
design, uma memória, um arquivo de persona) ou declarar uma ali mesmo, no
Passo 0. Seja qual for, os seis campos são declarados antes do primeiro achado.

1. **Nome e identidade em uma linha.** Quem ela é, numa frase que a equipe
   já usa.
2. **Piso de capacidade.** Visão, destreza, nível de leitura, aparelho, uma
   mão ou duas. Fixam os limites do portão de acessibilidade e o modelo de
   alcance da lente de ergonomia.
3. **Comportamento de leitura.** Quase todo mundo passa os olhos, fica com
   a primeira opção boa o bastante e vai se virando (Krug); uma persona pode
   ser ainda menos paciente. Diga isso.
4. **Ansiedades.** Do que ela tem medo nesta tela: perder dinheiro, quebrar
   alguma coisa, levar a culpa, parecer boba, não saber se deu certo. As
   perguntas da leitura em voz alta da lente do texto vêm daqui.
5. **A tarefa.** O que ela veio fazer, nas palavras dela. A revisão percorre
   a tela como ela, fazendo isso. O usuário a dá; quando não dá, o revisor
   propõe uma e a marca como suposição no topo do relatório, para que um
   leitor possa recusar a tarefa em vez dos achados.
6. **Cegueira.** A persona lê **a frio**: sem histórico da sessão, sem
   roadmap, sem explicação da equipe. A leitura em voz alta protege quem não
   está por dentro da piada. Nunca ponha a intenção no pedido à persona.

## A padrão: a persona ingênua ("o Novato", ou "a Novata")

Uma figura retórica do leitor menos técnico que o produto ainda promete
atender, o dono do negócio incluído. Não é uma pessoa real nem uma idade: é
um perfil de capacidade e de ansiedade.

- **Identidade.** Alguém na primeira vez, encontrando esta tela a frio, no
  próprio celular, provavelmente com uma mão só, provavelmente
  interrompido.
- **Piso de capacidade.** Óculos de leitura: texto corrido de 16 px ou mais
  no celular, de preferência 18 px; contraste de 4,5:1. Um polegar
  instável: alvos de 44×44 px ou mais, e o próximo alvo não tão colado que
  dê para tocar errado. Sem jargão, sem ícones sem rótulo, sem hover. Uma
  mão: as ações frequentes dentro da zona fácil do polegar.
- **Comportamento de leitura.** Passa os olhos, toca a primeira coisa
  plausível, não lê instruções, não lembra o que a tela anterior disse.
- **Ansiedades.** Quatro perguntas em toda tela de espera ou de status:
  minha coisa está segura? o que está acontecendo, e por quanto tempo?
  posso sair? vão me avisar? Quatro em toda ação: o que exatamente acontece
  se eu tocar? quanto custa ou compromete, e posso voltar atrás? o que
  preciso ter à mão? como desisto? (Protocolo em `texto.md`.)
- **Tarefa.** Dada a cada revisão. Sem ela, a persona é só um estado de
  espírito, não uma lente.

A satisfação dela é o que a camada retórica opcional da
`matriz-de-decisao` finge medir, e essa camada leva o nome dela ("Índice do
Novato") quando ela é a persona carregada. Este arquivo é dono da persona;
aquela skill é dona da retórica.

## Lugares

Num produto de vários usuários, a mesma tela se lê de **lugares**
diferentes: a pessoa a quem a tela pertence, a pessoa a quem se pede ajuda,
o terceiro que observa. Um lugar não é uma persona: é o usuário em cuja
posição a persona se coloca. Quando o produto tem lugares, revise a tela de
cada lugar que tem uma ação nela, e diga a que lugar pertence cada achado.
Um botão perfeito para o dono e sem sentido para quem ajuda é um achado no
lugar de quem ajuda. Quando o usuário restringe a revisão a um lugar, essa
restrição vence: os outros lugares com ações na tela são listados pelo nome
em "Não avaliado", nunca pulados em silêncio.

Os lugares também enquadram uma execução da `matriz-de-decisao`: uma opção
que dá uma tela a um lugar e deixa outro sem nenhuma é sinal de peça
faltando para o passo de hibridizar.

## Declarar outra persona

Diga os seis campos. Não invente idade, atraso de clique ou números de
paciência; uma persona com tempo de reação falso é teatro, não lente. Se a
equipe publicou uma persona (uma promessa de marketing, um documento de
design), cite-a como a linha de identidade e diga de onde veio: a revisão
então põe em prática a promessa que o próprio produto declarou, e não uma
invenção do revisor.
