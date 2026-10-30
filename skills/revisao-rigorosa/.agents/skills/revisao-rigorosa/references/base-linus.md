# A base Linus

O conjunto fixo de objeções que o eixo Normas aplica quando o repositório
não documenta nada em contrário. Cada item é uma questão de julgamento,
rotulada como tal no achado, e uma norma documentada do repositório
prevalece sobre ele. Cole este arquivo inteiro no prompt do subagente de
Normas.

Cada linha é a objeção como um mantenedor a diria, depois o que o autor
tem de fazer.

## Abordagem

Pergunte estas primeiro. Elas encerram mais mudanças do que tudo o que vem
abaixo somado.

- **"Isto trata o sintoma. De onde vem o dado ruim?"** Conserte quem o
  escreve, ou diga na mensagem de commit por que quem o lê é o lugar
  certo.
- **"Camada errada. Quem mais lê isto e ainda vê o bug?"** Conserte onde
  todos os consumidores ganham.
- **"Queremos isto?"** Uma capacidade que ninguém pediu não se salva por
  estar bem escrita.
- **"Isto acrescenta código que nada chama."** Ele entra junto com o
  primeiro uso.

## Estruturas de dados

- **"Qual é o dado central, e de quem ele é?"** Se a mudança não sabe
  dizer quem cria, altera e lê cada parte do estado, o design não está
  pronto.
- **"Por que isto é copiado ou convertido?"** Elimine as transformações
  que só existem para alimentar uma interface que não casa.
- **"Dá para explicar o arranjo num parágrafo?"** Se não, a estrutura está
  errada ou sem documentação.

## Casos especiais

Bom gosto é ver o problema de um ângulo em que o caso especial some. O
exemplo clássico: remover um item de uma lista simplesmente encadeada com
um desvio para "é a cabeça?" fica sem desvio quando o código percorre um
ponteiro para o elo em vez de um ponteiro para o nó.

- **"Caso especial para o primeiro, o vazio ou o que falta."** Mude a
  representação para que ele não seja especial, ou explique por que tem de
  ser.
- **"Uma pilha de condicionais sobre o mesmo valor."** Conserte o modelo
  de dados, ou troque a cascata por uma tabela que todos os pontos
  compartilham.

## Complexidade

- **"Isso é uma classe com um método. É uma função."**
- **"Classe base com uma implementação."** Apague a classe base.
- **"Um objeto de configuração para dois parâmetros."** Passe os
  parâmetros.
- **"Módulo auxiliar novo para um só chamador."** Ponha-o ao lado do
  chamador.
- **"Abstração nova, um usuário."** Ponha-a em linha; extraia-a no
  terceiro usuário.
- **"Opções que ninguém pediu."** Apague-as até aparecer uma necessidade
  real.
- **"Mais de três níveis de aninhamento."** Cláusulas de guarda, retornos
  antecipados, ou divida na emenda.
- **"Engenhoso."** Torne-o óbvio.
- **"Número mágico."** Dê-lhe um nome.
- **"Duplicata de uma função existente."** Reutilize-a, e diga-o.

## Nunca quebre o espaço do usuário

- **"Isto muda um comportamento de que quem chama depende."** Procure
  todos os que chamam cada assinatura, valor de retorno, rota, flag e
  formato guardado que mudou. Uma regressão é um bug mesmo quando o modelo
  novo é mais limpo.
- **"Dados guardados escritos pelo código antigo: o que os lê agora?"**
  Uma mudança de formato pede uma migração ou um leitor que aceite os
  dois.
- **"Os usuários que mudem" não é argumento.** Mantenha o contrato
  antigo, ou torne a quebra explícita, documentada e combinada.

## Prova acima de confiança

- **"Mostre os números."** Uma afirmação de desempenho sem medida é
  palpite.
- **"Mudança de comportamento sem teste."** Teste-a na mesma mudança.
- **"O teste verifica chamadas, não resultados."** Verifique o resultado.
- **"Catch amplo" ou "capturado e ignorado".** Capture o erro que você
  espera e trate-o, ou deixe-o propagar.
- **"Uma entrada que falta vira um valor em silêncio."** Diga no código o
  que significa faltar.

## Mudanças cirúrgicas

- **"Isto reformata linhas que você não mudou de outro modo."** Desfaça,
  ou mova a reformatação para um commit próprio.
- **"Você renomeou coisas e mudou lógica no mesmo commit."** Primeiro a
  renomeação, depois a lógica.
- **"Mudança alheia de dependência, lockfile ou configuração."** Um commit
  próprio com a própria razão, ou fora.
- **"Cada linha mudada precisa de uma razão."** O que não tem razão é
  ruído.
