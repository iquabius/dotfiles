# Exemplos de mensagem de commit

As mensagens de exemplo ficam em inglês: ilustram um repositório escrito
em inglês e são amostras da saída, não texto a traduzir.

Os números destes exemplos representam fatos que o autor deles tinha em
mãos. Nunca copie um número para uma mensagem real sem uma fonte para ele.

## Ruim: a saída típica de um agente

```
feat: add dedupe and improvements

- Added DedupeConfig and DedupeStrategy classes
- Refactored loader for better maintainability
- Improved report formatting
- Added comprehensive tests
- Updated dependencies
```

Cinco mudanças, nenhum problema, nenhum motivo. "Better maintainability" e
"improved" não carregam informação nenhuma, e "comprehensive" é um
veredito de revisão que o autor não tem direito de dar. Divida, e escreva
cada mensagem a partir do problema.

## Bom: uma correção de comportamento, o segundo de dois commits

```
loader: drop duplicate (ticker, date) rows, keeping the last

The vendor file repeats a row whenever a close is restated, so
load_prices() returns two rows for the same ticker and date and every
downstream mean is weighted toward restated days. Last week's report
showed AAPL with 23 trading days in a 21-day month.

Keep the last occurrence, since a restatement supersedes the original.
Using file order rather than a timestamp is deliberate: the vendor
file carries no restatement time, so file order is the only ordering
there is.

Tickers are normalised by the previous commit; this one relies on it,
so "aapl" and "AAPL" on the same date count as one row.

Means already written to the report table are wrong for any ticker
with a restated day; recomputing them is a follow-up.

Test: tests/test_loader.py::test_duplicate_dates_keep_last fails on
the parent commit and passes here.

Fixes: 3f1c2ab9d0e4 ("loader: read the vendor price file")
```

## Bom: o mesmo tipo de correção na forma Conventional Commits

As regras de conteúdo não mudam quando o repositório usa um prefixo
`type(scope):`. Só muda a forma do assunto.

```
fix(loader): uppercase tickers on read

Rows arrive with mixed-case tickers ("aapl", "Aapl", "AAPL") and every
consumer compares them as strings, so one instrument is counted up to
three times in the report.

Normalise at the boundary, in load_prices(), so no consumer has to.
Doing it in report.py instead would fix the report and leave
transform.py wrong.

Test: tests/test_loader.py::test_tickers_are_uppercased fails on the
parent commit and passes here.
```

## Bom: um deslocamento puro

```
report: move summarise() above write_report()

write_report() calls summarise(), and the next commit changes
summarise() in a way that is easier to review with the callee above
the caller. Moved verbatim.

No functional change.
```

## Bom: só o assunto

Uma mudança que se explica sozinha não precisa de corpo.

```
docs: fix the broken link to the install guide
```

## Reescrever uma mensagem fraca

Antes:

```
fix: update session handling
```

Faça as três perguntas a que o corpo tem de responder. O que estava
errado? (As sessões expiravam no meio da requisição, e a chamada que
renova o token entrava de novo em si mesma.) Por que esta correção? (Uma
flag de guarda é menor que tirar a renovação do middleware, de que toda
rota depende.) Como se testou? (Um teste nomeado que fica em laço no
commit pai.) Então escreva:

```
fix: stop the token refresh loop on expired sessions

When a session expires mid-request, the auth middleware refreshes the
token, the refresh itself fails validation, and the middleware refreshes
again until the request times out.

Abort the cycle with a guard flag when a refresh is already in flight,
and return a clean 401. Moving refresh out of the middleware would also
break the loop, but every route depends on the middleware's current
contract, so that is a larger change for another commit.

Test: test_expired_session_returns_401 loops on the parent commit and
passes here.
```
