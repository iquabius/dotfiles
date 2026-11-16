# Heurísticas — a lente da usabilidade

Condensado do `ux-heuristics` da wondelai (MIT; ver
`../THIRD_PARTY_NOTICES.md`). Ficou o que um avaliador precisa para nomear
uma violação e dar a ela uma severidade. Saíram as tabelas de padrões de
texto e o total de 0 a 10 sem âncora, que esta skill troca pelas faixas de
veredito de `relatorio.md`.

O fundamento: as pessoas têm paciência e atenção limitadas. Elas passam os
olhos, ficam com a primeira opção razoável e vão se virando em vez de
entender como as coisas funcionam. Cada ponto de interrogação que surge na
cabeça de quem lê é carga cognitiva e uma chance de ir embora. A lente
procura os pontos de interrogação.

## As três leis de Krug, mais o teste do porta-malas

**1. Não me faça pensar.** Nomes espertos perdem para nomes claros;
categorias estranhas obrigam a interpretar; um link que pode levar a
qualquer lugar cria dúvida. Sintomas: rótulos enigmáticos ("Soluções"),
"clique aqui", opções sem explicação, esperteza gratuita. Se um rótulo
precisa de explicação, o achado é o rótulo.

**2. Os cliques não importam; a confiança, sim.** Três toques confiantes e
sem esforço equivalem a um que pede deliberação. As pessoas desistem
quando perdem a confiança, não quando acaba a paciência. O achado aqui é o
passo em que quem lê não consegue saber se está no caminho certo.

**3. Corte metade das palavras, depois metade do que sobrou.** Conversa fiada
(happy talk: "Bem-vindo!"), instruções que ninguém lê, enchimento educado,
explicações repetidas. Se a pessoa vai pular, é ruído competindo com as
palavras que importam. O limite ético: a brevidade nunca tira uma informação
a que a pessoa tem direito (preço, condições, o que a ação compromete).

**O teste do porta-malas.** Largada a frio em qualquer tela, a pessoa
consegue responder: que produto é este? em que tela estou? quais são as
seções principais? o que posso fazer aqui? onde estou na estrutura? como
busco ou peço ajuda? Cada pergunta sem resposta é um achado de orientação.

**O reservatório de boa vontade.** Todo usuário chega com um reservatório
finito. Esvaziam: esconder a informação necessária, punir a pessoa por não
fazer do seu jeito, pedir dados desnecessários, fazê-la repetir o que já
disse, erros amadores. Enchem: responder às perguntas que ela tem, menos
passos, cuidado visível, recuperação fácil, um pedido de desculpas quando
algo dá errado. Use-o para pesar a persistência: um pequeno vazamento em
toda visita é um achado maior que um grande, uma vez só.

## As dez heurísticas de Nielsen

Para cada uma: o princípio, as violações a procurar e as âncoras de
severidade.

### 1. Visibilidade do status do sistema

Mantenha a pessoa informada, sem demora. Violações: nenhum estado de
carregamento (ela acha que quebrou); falha silenciosa (ela acha que deu
certo); retorno atrasado (ela toca de novo); nenhuma confirmação ("deu
certo?"); status escondido onde ela não vai olhar. Âncoras: salvar sem
"salvo" (1) · pagamento em processamento sem indicador (3) · enviar não
mostra nada e ela envia duas vezes (4).

### 2. Correspondência entre o sistema e o mundo real

Fale a língua dela, na ordem dela, com as metáforas dela. Violações: jargão
ou nomes internos nos rótulos; a mesma coisa com dois nomes (também viola a
4); ícones que ela tem de adivinhar; passos na ordem do sistema e não na da
vida; um controle que a faz manipular um conceito que ela nunca vive (um
botão de demonstração "avançar o tempo" numa tela que ela vive dia a dia).
Um termo por conceito, em todo lugar.

### 3. Controle e liberdade do usuário

Uma saída bem marcada de qualquer estado indesejado. **Desfazer vale mais
que "Tem certeza?"**: a pessoa passa pelas confirmações sem ler, mas age
com confiança quando pode voltar atrás. Violações: nada de desfazer (ela tem
medo de agir); um assistente forçado sem voltar nem pular; um modal sem
fechar; um botão de voltar sequestrado; exclusão imediata e permanente.

### 4. Consistência e padrões

As mesmas palavras, a mesma aparência e o mesmo comportamento para a mesma
coisa; as convenções da plataforma onde ela já as conhece. Violações: dois
estilos de botão para um mesmo nível de importância; uma palavra com dois
sentidos; um link que abre num lugar inesperado; um layout que muda de tela
para tela. Contam as duas: a consistência interna (dentro do produto) e a
externa (com a plataforma).

### 5. Prevenção de erros

Melhor que uma boa mensagem de erro é um design em que o erro não acontece.
Restrinja as entradas, sugira, escolha valores predefinidos sensatos, avise antes de
perder trabalho. Distinga **deslizes** (intenção certa, ação errada:
previna com tamanho, espaçamento, desfazer) de **enganos** (intenção
errada: previna com clareza e valores predefinidos). Violações: texto livre onde um
seletor serviria; nenhum aviso de alterações não salvas; uma ação
destrutiva a um toque descuidado de distância, sem desfazer.

### 6. Reconhecer em vez de lembrar

Mostre opções, itens recentes, valores decodificados e contexto; nunca a
faça lembrar algo de outra tela. Violações: campos vazios sem exemplo;
ações escondidas que ela tem de lembrar que existem; códigos em vez de
nomes; digitar de novo o que ela já deu; ícones sem rótulo.

### 7. Flexibilidade e eficiência de uso

Atalhos para os experientes que o novato nunca vê. As violações pesam menos
para a persona ingênua; anote-as para o lugar do especialista: nenhum
atalho, nenhuma ação em lote, um tutorial que não se pode pular. A revelação
progressiva resolve quase tudo isso.

### 8. Design estético e minimalista

Cada elemento a mais compete com os que importam; se tudo é importante,
nada é. Violações: amontoado; cinco chamadas para a ação competindo;
paredes de texto; cores demais; dois elementos na mesma tela fazendo o
mesmo trabalho (ver `SOBREPOSICAO` em `checagens.md`). O limite ético: o
minimalismo nunca esconde uma informação devida.

### 9. Ajudar a reconhecer, diagnosticar e se recuperar de erros

Linguagem simples, o que aconteceu, por quê (se ajudar), o que fazer. Nunca
um código, nunca culpa, nunca um formulário apagado como castigo.
Violações: "Entrada inválida"; "Erro 500"; um erro sem próximo passo; uma
mensagem que descreve a situação quando a pessoa precisa de uma instrução.

### 10. Ajuda e documentação

O melhor é não precisar dela; se não der, contextual, focada na tarefa,
curta. Violações: ajuda escondida; um documento longo onde uma dica
bastaria; ajuda genérica que não responde à pergunta desta tela.

## Estados — a lente que pergunta "e depois?"

Uma tela é um conjunto de estados, e o protótipo costuma mostrar um. Para
cada lista, cada ação e cada pedido que a tarefa envolve, pergunte e
renderize:

- **Vazio.** A lista não tem nada. A tela diz isso, e diz o que fazer? (Um
  estado vazio que ainda mostra o cartão de ajuda é uma escolha de design;
  um estado vazio que não mostra nada é `ESTADO-FALTANDO`.)
- **Carregando.** Tudo o que passa de mais ou menos um segundo mostra
  progresso (Nielsen 1).
- **Erro.** A ação falhou: a causa em palavras simples, um próximo passo, o
  que a pessoa informou preservado (Nielsen 9; `ERRO-SEM-PROXIMO-PASSO`).
- **Sucesso.** Ela consegue saber que deu certo, e o que acontece depois
  (Nielsen 1).
- **O outro lado disse não.** Em todo produto com contraparte (um pedido,
  uma oferta, uma aprovação), a recusa é um estado de primeira classe: quem
  recusou, por quê, se se sabe, e o que ela pode fazer agora. Uma recusa
  que nunca expira e não oferece próximo passo é `ERRO-SEM-PROXIMO-PASSO` com
  severidade 3; uma recusa que nomeia o ator errado é `STATUS-FALSO`.
- **Desabilitado e esperando.** Por que está desabilitado; quanto dura a
  espera; ela pode desistir enquanto espera (Nielsen 3).

Os estados que a demonstração pula (uma contraparte roteirizada responde na
hora) se leem no código-fonte e ganham o grau `[Julgamento]`; diga quais
estados você renderizou e quais só leu.

## Severidade 0–4, com os três fatores

| Nota | Significado | Prioridade |
|---|---|---|
| 0 | Não é problema; discordância, não usabilidade | ignorar |
| 1 | Cosmético; incômodo pequeno | corrigir se houver tempo |
| 2 | Menor; atrasa ou frustra | agendar |
| 3 | Maior; falha significativa na tarefa | corrigir logo |
| 4 | Catastrófico; impede concluir a tarefa ou causa dano financeiro ou legal consumado | corrigir já |

Três fatores fecham o número: **frequência** (quantas vezes a pessoa topa
com ele), **impacto** (quão ruim é quando topa), **persistência** (um
tropeço único ou toda visita). Escreva os fatores no cartão; um dígito
sozinho não é evidência.

## Diagnóstico rápido (dez perguntas, a frio)

Percorra a tela como a persona e responda a cada uma. Um "não" é um achado
candidato na heurística indicada.

1. Dá para saber de cara que produto e que tela é esta? (teste do
   porta-malas)
2. A ação principal é óbvia? (8; uma ação primária)
3. A navegação é clara, e eu sei onde estou? (teste do porta-malas, 6)
4. Acho a busca ou a ajuda se precisar? (10)
5. O sistema me mostra o que está acontecendo? (1)
6. As mensagens de erro me dizem o que fazer? (9)
7. Posso desfazer ou voltar? (3)
8. Funciona sem passar o mouse por cima? (celular, teclado)
9. Todo elemento interativo tem rótulo? (2, 6)
10. Alguma coisa me faz parar e pensar "hã?" (Krug 1)

## Erros comuns que se escondem à vista

Ícones-mistério sem rótulo · escolhas demais · nenhum "você está aqui" ·
nenhuma validação no campo · paredes de texto · jargão nos rótulos · nenhum
estado de carregamento · alvos de toque abaixo de 44 px · informação só ao
passar o mouse · nada de desfazer · "Entrada inválida" · contraste abaixo de
4,5:1 · navegação que muda de lugar · um botão de voltar quebrado.
