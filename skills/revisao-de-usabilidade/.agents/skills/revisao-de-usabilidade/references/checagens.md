# Checagens — IDs estáveis para os achados

Um ID torna um achado citável entre revisões, buscável num log de decisões
e comparável entre iterações da mesma tela. Use o ID que servir; quando
nenhum servir, escreva `NOVO:<nome-em-kebab>`. Se ele se repetir nesta
revisão, sugira em "Encaminhamentos" sua promoção com uma definição de uma
linha; quem mantém a skill decide e edita este arquivo. As severidades são
pontos de partida; frequência, impacto e persistência fecham o número. Os
IDs e os graus de evidência ficam como estão escritos aqui em toda língua
de relatório.

## Portões (relatados primeiro; sem nota)

A tabela completa do piso de acessibilidade está em `acessibilidade.md`;
os IDs abaixo cobrem parte dela. Esta tabela nomeia os portões e suas
fontes.

| ID | Definição | Fonte |
|---|---|---|
| `BECO-SEM-SAIDA` | o caminho da tarefa chega a um estado sem nova tentativa, sem saída e sem próximo passo, as três ausências juntas (julgue o caminho, não a tela inteira; confira o caminho humano que uma demonstração pode pular) | Nielsen 3, 9 |
| `IRREVERSIVEL` | uma perda, cobrança, envio ou atribuição sem desfazer e sem escolha consciente (consciente = ela sabe de antemão o efeito e a contraparte) | Nielsen 3, 5 |
| `TAMANHO-DO-ALVO` | um elemento acionável abaixo do piso de toque (44×44 px: Apple HIG e o piso da persona; a WCAG 2.2, 2.5.8 AA, fixa 24×24 px CSS, com exceções, inclusive de espaçamento e de alvo em linha) | HIG; WCAG 2.5.8 |
| `CONTRASTE` | texto abaixo de 4,5:1 (3:1 para texto grande e componentes de interface) | WCAG 1.4.3, 1.4.11 |
| `SO-COR` | sentido carregado só pela cor | WCAG 1.4.1 |
| `TAMANHO-DO-TEXTO` | texto corrido abaixo de 16 px no celular; texto corrido = texto necessário à tarefa (frases, rótulos de ação e de campo, status, mensagens de erro, eixos e legendas); etiquetas de metadados, carimbos de hora e rótulos de abas recebem nota, não portão (abas são a exceção entre os rótulos de ação) | piso da persona |
| `TEXTO-TRANSBORDA` | o texto transborda ou é cortado com o comprimento típico dos valores que preenchem os campos variáveis (um portão do domínio declarado) | caber no layout, texto.md |

## Usabilidade

| ID | Definição | Fonte | Sev |
|---|---|---|---|
| `ACAO-AMBIGUA` | o rótulo da ação principal não diz o que acontece | Krug 1; Nielsen 2 | 2–3 |
| `STATUS-MUDO` | uma ação ou espera sem retorno, ou uma falha silenciosa | Nielsen 1 | 2–4 |
| `STATUS-FALSO` | uma linha de status afirma algo falso (o ator errado, o estado errado) | Nielsen 1, 9 | 3 |
| `SEM-DESFAZER` | uma ação reversível em princípio não oferece desfazer, ou a janela do desfazer é curta demais para se notar | Nielsen 3 | 2–3 |
| `CONFIRMA-EM-VEZ-DE-DESFAZER` | um "tem certeza?" onde um desfazer serviria | Nielsen 3, 5 | 1–2 |
| `JARGAO` | uma palavra do sistema ou do mecanismo que a persona não consegue entender | Nielsen 2 | 2–3 |
| `TERMO-VARIA` | um conceito com dois nomes, ou um verbo cujo registro contradiz o declarado | Nielsen 2, 4 | 2–3 |
| `CUSTO-DE-LEMBRAR` | ela precisa lembrar algo de outra tela | Nielsen 6 | 2 |
| `TESTE-DO-PORTA-MALAS` | ela não consegue dizer onde está ou o que é isto | Krug | 2–3 |
| `CONVERSA-FIADA` | palavras que ela vai pular, competindo com palavras que importam | Krug 3; Nielsen 8 | 1 |
| `ERRO-SEM-PROXIMO-PASSO` | um estado de erro, recusa ou falha sem causa clara ou sem uma das opções: nova tentativa, saída, próximo passo; se as três faltam, use o portão `BECO-SEM-SAIDA` | Nielsen 9 | 2–3 |
| `ESTADO-FALTANDO` | estado vazio, carregando, erro, sucesso ou "o outro lado disse não" ausente ou não tratado | Nielsen 1, 5, 9 | 2–3 |
| `MAQUINA-DO-TEMPO` | um controle que faz a persona manipular um conceito que ela nunca vive (avançar o tempo, um botão de demonstração numa tela de uso real) | Nielsen 2 | 2 |

## Ergonomia e hierarquia

| ID | Definição | Fonte | Sev |
|---|---|---|---|
| `ALCANCE-DO-POLEGAR` | uma ação frequente fora da zona natural de uma mão só | zona do polegar | 2–3 |
| `RARO-NO-NOBRE` | uma ação rara (demonstração, repetição, configurações) ocupando o alcance nobre ou a posição primária | zona do polegar; Nielsen 8 | 2 |
| `ENCOBERTO` | um elemento acionável que cruza o retângulo de uma barra sticky, ou abaixo da dobra sem indicação | medido | 3–4 |
| `UMA-PRIMARIA` | mais de um elemento no nível primário da hierarquia, ou a ação-chave da tarefa com menos destaque visual que as rotineiras | hierarquia visual; Krug 1 | 2 |
| `HIERARQUIA-PLANA` | o teste de apertar os olhos falha; nada conduz | hierarquia visual | 2 |
| `ORDEM-TROCADA` | a ordem de leitura estimada pela posição e pelo peso discorda da ordem da tarefa | hierarquia visual | 2 |
| `SO-HOVER` | informação ou ação que só se alcança com hover | Nielsen 6; WCAG 1.4.13 para conteúdo adicional em hover/foco, 2.1.1 para operação pelo teclado | 3 em toque |

## Texto

| ID | Definição | Fonte | Sev |
|---|---|---|---|
| `LEITURA-EMPACA` | a persona, lendo a frio, empaca, chuta ou acha duas leituras; ou uma pergunta de status ou de ação fica sem resposta | protocolo de texto.md; Nielsen 1, 9 | 2–3 |
| `AFIRMACAO-ALEM-DA-EVIDENCIA` | um número dito está num degrau que o grau de evidência não sustenta (ou fica aquém da evidência medida) | escada de texto.md | 2–4 |
| `SEM-ANCORA` | o texto cai para o silêncio sem nada que cumpra o dever de âncora | escada de texto.md | 1–2 |
| `PESSOA-VARIA` | pessoa gramatical inconsistente numa mesma superfície, contra o registro declarado | pessoa em texto.md | 1–2 |
| `ROTULO-FAZ-CONVERTER` | um rótulo a faz converter unidades para responder "quando" ou "quanto" | texto.md; Nielsen 2 | 2 |
| `NUMERO-DUPLICADO` | uma quantidade mostrada em dois lugares, calculada de dois jeitos | fonte única em texto.md | 2–3 |
| `ITEM-DUPLICADO` | o mesmo item exibido duas vezes numa tela sem papéis distintos | fonte única em texto.md; Nielsen 8 | 2 |
| `ELOGIO-EM-VEZ-DE-FATO` | um status dito como elogio ou culpa (em palavras ou em estilo de alarme) onde o registro pede um fato neutro | texto.md; aversão à desigualdade | 1–2 |

## Exibição de dados

| ID | Definição | Fonte | Sev |
|---|---|---|---|
| `GRAFICO-ERRADO` | o tipo de gráfico briga com a forma dos dados | exibicao-de-dados.md | 2 |
| `FALSO-ZERO` | um período ausente exibido como zero; não se refere à base do eixo | exibicao-de-dados.md | 2–3 |
| `BASE-TRUNCADA` | barras com base diferente de zero sem aviso | exibicao-de-dados.md | 2–3 |
| `HORIZONTES-MISTURADOS` | números numa tela de horizontes de tempo diferentes sem rotular a natureza | exibicao-de-dados.md | 2–3 |
| `RANKING-EM-JUSTICA` | pessoas ranqueadas numa tela que mede divisão justa de trabalho; não inclui desempenho comercial | exibicao-de-dados.md; aversão à desigualdade | 2 |
| `META-INVISIVEL` | a linha justa ou da meta ausente, ou um valor na meta escondido por uma marca de comprimento zero | exibicao-de-dados.md | 1–2 |

## Persuasão

| ID | Definição | Fonte | Sev |
|---|---|---|---|
| `PADRAO-OBSCURO:<subtipo>` | um dos oito padrões sem ID próprio (continuidade-forcada, motel-de-baratas, privacidade, isca-e-troca, custo-escondido, desvio-de-atencao, pergunta-capciosa, item-na-cesta) | persuasao.md | 3–4 |
| `CULPA-NA-RECUSA` | a opção de recusar faz a persona sentir culpa (padrão 5, ID próprio) | persuasao.md | 3–4 |
| `FALSA-URGENCIA` | urgência ou escassez que não é verdadeira (padrão 10, ID próprio) | persuasao.md | 3–4 |
| `EMPURRAO-CONTRA` | uma opção predefinida, um destaque ou um sinal de progresso que serve ao produto contra a persona | persuasao.md | 2–3 |

## Consistência e estrutura

| ID | Definição | Fonte | Sev |
|---|---|---|---|
| `UM-PADRAO` | N variantes da mesma interação onde um padrão bastaria (o caso especial da interface) | Nielsen 4, 8 | 2 |
| `SOBREPOSICAO` | dois elementos sem papéis distintos que a persona saiba nomear | teste contra sobreposição; Nielsen 8 | 1–2 |
| `CEGO-AO-LUGAR` | um controle ou texto certo para um lugar e sem sentido ou errado para outro lugar que tem uma ação aqui | lugares em personas.md | 2–3 |

## Pontos positivos (relatados em "Manter")

Achados não são só defeitos. Quando um elemento faz seu trabalho tão bem que
os consertos não podem mexer nele, registre-o com `MANTER:<id>` (por exemplo
`MANTER:DESFAZER`, `MANTER:SEM-OCLUSAO`, `MANTER:RARO-NO-CANTO`,
`MANTER:PRIMEIRA-PESSOA`). Uma revisão sem nenhum "manter" está revisando um
desastre ou não está olhando.
