# Quando as heurísticas brigam

Heurísticas são diretrizes, e numa tela real elas puxam umas contra as
outras. Dois achados que se contradizem não são um empate a tirar na média;
são uma decisão a tomar conscientemente, pelo contexto, e a registrar.
Condensado da `ux-heuristics` da wondelai (MIT; ver
`../THIRD_PARTY_NOTICES.md`), com a regra dos fatores de contexto que esta
skill partilha com a `matriz-de-decisao`.

## Os cinco conflitos recorrentes

| Conflito | Penda para um lado quando… | Penda para o outro quando… | Solução que atende aos dois |
|---|---|---|---|
| **Simplicidade contra flexibilidade** (Krug; Nielsen 3, 7) | novato, uso ocasional, pouco em jogo, pressa | especialista, uso diário, muito em jogo | revelação progressiva: opção predefinida simples, poder por baixo |
| **Consistência contra contexto** (Nielsen 4 contra 2) | usuários diversos, curva de aprendizado, ação comum, modelo mental estabelecido | usuários uniformes, ação rara, modelo ainda se formando | padrões consistentes, destaque conforme o contexto |
| **Eficiência contra prevenção de erros** (Nielsen 7 contra 5) | reversível, erro barato, usuários avançados, muito frequente | irreversível, caro, usuários novos, raro | desfazer em vez de confirmar; atrito na medida do risco |
| **Descoberta contra minimalismo** (Nielsen 6 contra 8) | recursos centrais, iniciantes, tarefas simples, espaço de sobra | recursos periféricos, especialistas, tarefas complexas, pouco espaço | o primário à vista, o secundário em menus; revelação conforme o contexto |
| **Orientação contra controle** | novato, recuperação difícil, regras estritas | especialista, recuperação fácil, sistema tolerante | avisos, não bloqueios; "tem certeza?" em vez de "você não pode" |

## O movimento da resolução

1. **Nomeie o conflito.** Que princípio diz A, qual diz B, por que os dois
   não podem ser atendidos por inteiro.
2. **Avalie o contexto.** Quatro fatores decidem a maioria dos conflitos:
   **tipo de usuário** (novato ou especialista), **criticidade da tarefa**,
   **reversibilidade** e **frequência do caminho**. Escreva o que importa
   aqui.
3. **Recomende a prioridade para este contexto; o D decide.** Crítico e
   irreversível → prevenção acima de eficiência. Frequente e com pouco em
   jogo → eficiência. Usuários novos → orientação. Tela pequena e tarefa
   focada → minimalismo. Uma interface de aprendizado → descoberta.
4. **Procure primeiro a solução que atende aos dois.** Desfazer em vez de
   um diálogo de confirmação. Revelação progressiva em vez de remoção.
   Padrão consistente com ênfase variável. A maioria dos conflitos se
   dissolve aqui.
5. **Registre a recomendação no cartão.** A frase que nomeia o fator
   decisivo costuma bastar. Se o D decidir mudar o produto, ofereça o
   registro de decisão; só o escreva no log do projeto se houver pedido.

## Cenários comuns, resolvidos

- **Boas-vindas (onboarding):** deixe pular, mostre o valor, adie para
  momentos do contexto.
- **Navegação no celular:** uma barra de abas para três a cinco itens
  principais; um menu para o resto; o controle raro de demonstração ou de
  repetição num canto, não na barra.
- **Validação de formulário:** valide ao sair do campo, no próprio campo,
  nunca em modal; deixe enviar e mostre todos os erros.
- **Diálogos de confirmação:** confirme só ações irreversíveis e de custo
  alto; ofereça desfazer nas outras; diga a consequência com clareza.
- **Opções predefinidas:** sensatas para a maioria, fáceis de mudar, nunca
  exigidas antes de começar.

## O teste contra sobreposição (uma heurística da casa)

Quando dois elementos numa tela parecem fazer o mesmo trabalho (uma linha
de veredito e um medidor; um selo e um rótulo), tente escrever uma frase
que dê a cada um um papel distinto, nas palavras da persona. Se não
conseguir, junte-os; o achado é `SOBREPOSICAO` em Nielsen 8. Esta é uma
heurística da casa, não ciência citada, e o cartão diz isso.

## Documentação da decisão

Quando uma revisão resolve um conflito e o produto muda, ofereça este
registro (o formato que a `matriz-de-decisao` também usa):

```
<data> — <decisão, nas palavras da equipe>. D: <quem decidiu>.
Base: <a revisão ou a matriz>. Fator decisivo: <tipo de usuário / criticidade /
reversibilidade / frequência — qual, e por quê>. Alterações do D: <nenhuma, ou o que
o D mudou em relação à recomendação>.
```
