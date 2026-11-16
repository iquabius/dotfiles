# Relatório — o cartão, o modelo, as faixas, a voz

Leia isto antes de escrever qualquer relatório. A forma é fixa para que duas
revisões da mesma tela com um mês de distância se comparem, e para que um
leitor que não assistiu à revisão receba o veredito na primeira seção. A
prosa vai na língua do usuário; os IDs das checagens e os graus de
evidência ficam como estão escritos aqui, para que os relatórios se busquem
do mesmo jeito em toda língua.

## O cartão de achado

```
### <n>. <ID-DA-CHECAGEM> — <título de uma linha nas palavras da persona>
Onde:       <seletor | retângulo x,y,w,h em <viewport> | "texto citado, literal">
Errado:     <o que está errado, especificamente>
Custa:      <o que isso faz à persona, nas palavras dela>
Cita:       <Nielsen nº n | lei de Krug | WCAG n.n.n | zona do polegar | degrau da escada | heurística da casa | palpite>
Severidade: <0–4> — frequência <…>, impacto <…>, persistência <…>
Grau:       [Medido] | [Observado] | [Julgamento] | [Afirmado]
Conserto:   Antes   — <atual>
            Depois  — <proposto>
            Por quê — <uma linha>   (operação: renomear | mover | juntar | dividir | remover | medir | reescrever)
Lugar:      <dono | quem ajuda | terceiro>   (só quando o produto tem lugares)
```

Regras: uma citação tem de se achar de novo byte a byte; um retângulo tem
de vir de uma medição, ou o grau diz `[Julgamento]`; um cartão sem citação
escreve `palpite` na linha Cita; um cartão que só parafraseia a tela é
descartado.

## O modelo de relatório

```
# Revisão de usabilidade — <o que foi revisado>

**Escopo:** <tela / fluxo / controle / texto / gráfico>; camadas da primeira visita: <fechadas | abertas | as duas>
**Superfície:** <viewport, DPR, classe de aparelho, tema; app renderizado | captura de tela | arquivo de design>
**Persona:** <nome>, tarefa: "<nas palavras dela>" <(suposta pelo revisor) se o usuário não deu nenhuma>
**Lugar(es):** <revisados>; outros lugares com ações aqui: <listados em Não avaliado>
**Registro:** <documento declarado, ou "nenhum declarado; lente do registro inerte">
**Lentes rodadas:** <lista>; puladas: <lista, com o porquê>
**Ferramentas:** <navegador/DevTools usados, estados percorridos na passada de medição, ou nenhuma>

## Veredito: <Alto risco | Precisa de trabalho | Sólido>
<uma frase: o motivo, nomeando a(s) falha(s) de portão ou o pior achado>

## Corrija isto primeiro
<uma mudança e os IDs dos cartões que ela fecha; quando vários portões independentes falham, a mudança de efeito mais largo>

## Achados (em ordem)
<no máximo seis cartões, severidade decrescente; empates decididos pela frequência>

## Manter
<MANTER:<id> — o que funciona e tem de sobreviver aos consertos; uma linha cada>

## Não avaliado
<teclado, leitor de tela, movimento, zoom, tempos, estados não renderizados, lugares pulados a pedido… — o quê e por quê>

## Encaminhamentos
- revisao-rigorosa: <observações de código, uma linha cada, ou "nenhuma">
- matriz-de-decisao: <uma bifurcação real entre alternativas, ou "nenhuma">
- banca: <texto que precisa de oficina, ou "nenhum">

## Registro de decisão (oferecido)
<o registro de uma linha abaixo, ou "nenhuma decisão mudou">

## Apêndice (quando há mais de seis achados ou notas da primeira visita)
<os cartões restantes, uma linha cada: ID · onde · severidade · grau; notas das camadas da primeira visita>
```

## Faixas do veredito

A faixa segue os cartões. Nunca ajuste um cartão para cair numa faixa.

| Faixa | Regra |
|---|---|
| **Alto risco** | qualquer falha de portão, ou qualquer cartão de severidade 4 |
| **Precisa de trabalho** | qualquer cartão de severidade 3, ou três ou mais cartões de severidade 2 |
| **Sólido** | nada acima de severidade 2, e menos de três em 2 |

"Nenhum achado" é um resultado válido: o relatório ainda leva o escopo, as
lentes rodadas, o que manter e o não avaliado, para que o leitor saiba o
que foi conferido.

## A ordem e o limite

Seis cartões no corpo, em ordem de severidade, empates pela frequência. Do
sétimo em diante vão para o apêndice, uma linha cada. O limite é o
orçamento do leitor; um relatório de vinte achados se lê como "está tudo
errado", o que nunca leva a uma ação.

## O contrato da voz

Neutra é o padrão: simples, específica, dirigida a quem vai agir. Uma
camada de voz, quando o usuário pede uma, reescreve **só o tom**:

- **Linus.** Veredito primeiro, sem ressalvas, seco sobre o design e nunca
  sobre uma pessoa, fecha duro. Comprime; um relatório Linus é mais curto.
  Toda frase dura tem de remeter a um cartão; uma crítica sem dó que você
  não sustenta com um cartão é grosseria, não revisão.
- Qualquer outra voz que o usuário nomear, no mesmo contrato.

Severidades, graus, textos citados, citações de fontes, a faixa e a lista
do não avaliado passam sem mudança por todas as vozes. A voz se escolhe a
cada pedido e nunca se guarda, porque uma voz guardada vaza para artefatos
de leitores que não a pediram. Responda na língua do usuário, seja qual for
a voz.

## Modo de comparação (duas renderizações de um design)

Quando o usuário entrega duas versões do **mesmo** design (antes e depois
de uma mudança, duas iterações de uma tela), rode a revisão em cada uma e
acrescente uma seção: **O que viraria a escolha**, o único achado que, se
consertado na versão mais fraca, mudaria qual das duas é melhor. Isto não é
arbitrar opções: dois ou mais designs de fato diferentes disputando o mesmo
espaço vão para a `matriz-de-decisao`, que é dona dos portões por opção,
dos vereditos par a par e das porcentagens opcionais. Nada de números
inventados aqui.

## Registro de decisão (oferecido, nunca escrito no log sem pedido)

O mesmo formato que a `matriz-de-decisao` e o `conflitos.md` usam:

```
<data> — <decisão, nas palavras da equipe>. D: <quem decidiu>.
Base: <título ou caminho desta revisão>. Fator decisivo: <tipo de usuário | criticidade | reversibilidade | frequência, e por quê>.
Alterações do D: <nenhuma | o que o D mudou em relação à recomendação>.
```
