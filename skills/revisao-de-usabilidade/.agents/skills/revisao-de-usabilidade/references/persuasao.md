# Persuasão — empurrão ou padrão obscuro

Toda interface persuade: uma opção predefinida, uma ordem, um botão destacado. A lente
traça uma linha só. A **persuasão** ajuda a persona a tomar a decisão que
ela tomaria se entendesse tudo; um **padrão obscuro** (dark pattern) a leva
a fazer o que ela não faria se entendesse. O mesmo mecanismo (uma opção predefinida, uma
contagem regressiva, uma caixa já marcada) cai de um lado ou do outro
conforme o interesse a que serve. Os manuais de marketing ficam fora desta
lente; a lente só marca a fronteira.

Taxonomia condensada do `ux-heuristics` da wondelai (MIT; ver
`../THIRD_PARTY_NOTICES.md`).

## Empurrões aceitos (com a guarda)

Estes estão bem quando servem ao objetivo da própria persona, e viram
achados no momento em que servem ao produto contra ela:

| Mecanismo | Serve a ela quando… | Fica obscuro quando… |
|---|---|---|
| uma opção predefinida | a opção predefinida é o que a maioria quer e se muda sem esforço | custa dinheiro, compartilha dados ou é difícil de reverter |
| gradiente de meta (progresso à mostra) | o progresso é real e terminar serve a ela | o progresso é fabricado para mantê-la indo |
| pico-fim (um bom último momento) | o fim confirma o que aconteceu | encobre um resultado pouco claro |
| pé na porta (um primeiro passo pequeno) | o passo pequeno é útil por si só | existe para arrancar compromisso para um pedido maior |
| prova social | a contagem é verdadeira e relevante | é inventada ou irrelevante |
| uma ação primária destacada | é a ação de que a tarefa dela precisa | é a ação que o negócio quer, e a dela fica rebaixada |
| a aversão à desigualdade à mostra | mostra uma parte justa para as pessoas se reequilibrarem | ordena as pessoas para envergonhá-las |

## Os dez padrões obscuros

Os padrões 5 e 10 usam `CULPA-NA-RECUSA` e `FALSA-URGENCIA`; os outros
oito usam `PADRAO-OBSCURO:<subtipo>`, com os subtipos de `checagens.md`
(`privacidade` para o padrão 3). A severidade é 4 quando há dano
financeiro ou legal consumado, e 3 nos demais casos.

1. **Continuidade forçada** (forced continuity) — fácil de começar, difícil
   de cancelar.
2. **Motel de baratas** (roach motel) — fácil de entrar, difícil de sair
   (excluir a conta, cancelar a inscrição).
3. **Privacy zuckering** — levada por engano a compartilhar mais do que
   pretendia.
4. **Isca e troca** (bait and switch) — o controle faz outra coisa que não a
   que diz (um "X" que envia; um "grátis" que cobra).
5. **Confirmshaming** — a opção de recusa a faz sentir culpa ("Não, não quero
   economizar"). `CULPA-NA-RECUSA`.
6. **Custos escondidos** (hidden costs) — tarifas reveladas no último passo.
7. **Desvio de atenção** (misdirection) — o design puxa a atenção para longe
   do que importa (condições em cinza miúdo; "Sim" em destaque, "Não"
   escondido; adicionais pré-selecionados).
8. **Perguntas capciosas** (trick questions) — negações duplas, caixas de
   seleção de sentido misturado, "Continuar" querendo dizer "Concordo".
9. **Item enfiado na cesta** (sneak into basket) — itens adicionados sem
   ação dela.
10. **Falsa urgência ou escassez** — contagens regressivas que recomeçam,
    "só restam 2" que não é verdade. `FALSA-URGENCIA`.

Nota regulatória: o consentimento obtido por vários destes é inválido pelo
GDPR e pelo California Privacy Rights Act; a FTC já agiu contra tarifas de
assinatura escondidas, cancelamento difícil e urgência falsa. Cite o padrão,
não a lei, a menos que a revisão seja para o jurídico.

## A lista de verificação (rode-a em toda tela que pede dinheiro, dados ou consentimento)

- Ela consegue cancelar tão fácil quanto se inscreveu?
- O custo total está claro antes do último passo?
- Cada item adicionado foi escolhido explicitamente?
- As opções de recusar são neutras e tão visíveis quanto as de aceitar?
- Cada botão faz exatamente o que o rótulo diz?
- A informação importante está em destaque visual, e não enterrada?
- Toda urgência ou escassez é real?
- As opções predefinidas respeitam a privacidade?

**O teste do espelho.** A equipe ficaria à vontade se um jornalista
descrevesse exatamente como isto funciona? Se não, provavelmente é um padrão
obscuro; o cartão deve dizer qual.

## Grau

Um achado de padrão obscuro é `[Observado]` quando o mecanismo está visível
na tela (uma caixa já marcada, uma contagem regressiva) e `[Julgamento]`
quando o dano depende de um comportamento que você inferiu (que a contagem
recomeça). Diga qual.
