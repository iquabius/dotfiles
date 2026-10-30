# Avisos de terceiros

Esta skill adapta partes substanciais do **review-ready**, de Gary Tang:

- Fonte: https://github.com/GaryTang32/review-ready
- Revisão: `5a6959a8bb5ae6554884d78e50f30bbb4526059e` (2026-09-21)
- Arquivo `references/commit-message.md`: o esqueleto da mensagem, as
  regras do corpo, a regra de que todo fato tem fonte, os trailers, o
  tamanho de assunto de uns 60 caracteres e a quebra do corpo em 72
  colunas (mantidos como valores padrão), e os exemplos comentados.
- Arquivo `SKILL.md`, seção "Ground rules": a definição de uma mudança
  lógica por commit, e a regra de nunca misturar movimento com
  modificação, renomeação com lógica, nem espaço em branco com qualquer
  outra coisa.

A adaptação deixa de fora as ferramentas de série de patches do
review-ready, o fluxo de `Signed-off-by:` e o prefixo de assunto `area:`.
Os números de tamanho e de quebra dele viram valores padrão, que cedem a
uma regra explícita ou a um precedente consistente na história do
repositório em que a skill trabalha. Ela também inverte a regra do
review-ready de nunca mencionar a ferramenta: por padrão, a mensagem
termina com o trailer de atribuição do agente de IA. E afrouxa a divisão:
partes que dividem uma mesma reestruturação ficam num commit só quando o
corpo diz por quê, e o movimento vai num commit próprio só quando
esconderia a mudança ou é uma reformatação ampla feita por uma
ferramenta, a menos que o repositório em que a skill trabalha peça cada
movimento à parte.

## Licença do material adaptado

```
MIT License

Copyright (c) 2026 Gary Tang

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
