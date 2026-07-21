# Design e Estrutura

## Mapeamento de conceitos: Webcolinas-Manager → django-helpdesk

O Webcolinas-Manager tem o seu próprio sistema de pedidos (`Request`), usado como referência para desenhar a estrutura de categorias aqui — sem ligação de dados entre os dois sistemas.

| Webcolinas-Manager (`Request`) | django-helpdesk | Notas |
|---|---|---|
| `serviceType` ("Servidor · Dificuldade Login", etc.) | `Queue` (fila) | Cada área de trabalho vira uma fila própria, com permissões e caixa de correio dedicadas |
| `channel` (EMAIL/PHONE/WHATSAPP/OTHER) | `CustomField` "canal" (lista) | Não existe campo de canal nativo no `Ticket`; usa-se um custom field em vez de sobrecarregar a fila |
| `status` (NEW/IN_PROGRESS/WAITING/RESOLVED/CLOSED/REOPENED) | `Ticket.status` (Open/Reopened/Resolved/Closed/Duplicate) | Ver tabela de equivalência abaixo — não foi criado nenhum estado novo |
| `RequestEvent` (nota/chamada/email/whatsapp) | `FollowUp` | Cada evento de um pedido corresponde a um follow-up no ticket |
| `contactEmail` | `Ticket.submitter_email` | Único campo de contacto nativo no `Ticket` |
| `contactName` / `contactPhone` | *(sem equivalente nativo)* | Se vierem a ser precisos, resolve-se com mais `CustomField`, não com alteração ao modelo `Ticket` |

### Tabela de equivalência de estados (referência, não aplicada automaticamente)

| Webcolinas `RequestStatus` | django-helpdesk `Ticket.status` |
|---|---|
| NEW | Open |
| IN_PROGRESS | Open |
| WAITING | Open (+ `on_hold=True`) |
| RESOLVED | Resolved |
| CLOSED | Closed |
| REOPENED | Reopened |

## Filas criadas

| Fila | Slug | Cobre |
|---|---|---|
| Servidores & Alojamento | `SRV` | Logins, indisponibilidade, criação de contas de alojamento |
| Email & Microsoft 365 | `MAIL` | Problemas de email e Microsoft 365 |
| Segurança & Alertas | `SEC` | Alertas automáticos (ex. Wordfence), incidentes de segurança |
| Geral | `GERAL` | Moodle/e-learning, novas plataformas, tudo o que não encaixa nas outras |

Ficheiro fonte: `demodesk/fixtures/webcolinas_categories.json`. Carregado via `python manage.py loaddata webcolinas_categories.json` (já incluído no alvo `demo` do `Makefile`).

## Decisões de design importantes

### Por que Filas (Queue) e não um campo de "categoria" no ticket?
Porque o django-helpdesk já liga às filas permissões de acesso, caixa de correio e escalamento — usar filas dá toda essa estrutura de graça, em vez de reinventar um campo de categoria solto sem essas capacidades.

### Por que um `CustomField` para o canal, e não uma fila por canal?
Canal (email/telefone/whatsapp) é uma dimensão diferente de área de trabalho (servidores/email/segurança/geral) — misturar as duas em filas geraria uma explosão de combinações. Um custom field mantém as duas dimensões independentes.

### Por que fixture e não um management command?
O `demodesk` não tem app própria (só consome `helpdesk` + config) — criar uma app só para um comando de setup seria mais código do que o problema justifica. Fixtures já são o mecanismo usado por este projecto (`demo.json`, `emailtemplate.json`); seguir o mesmo padrão é o caminho mais simples.

### Por que não importar os 36 pedidos reais do Webcolinas-Manager?
Decisão do utilizador: esses pedidos têm domínios de clientes reais, contactos e alertas de segurança de terceiros. Trazer isso para um sistema novo (que pode um dia ir para produção) não se justifica só para "ter tickets prontos" — a estrutura de categorias resolve o mesmo problema sem mover dados sensíveis.
