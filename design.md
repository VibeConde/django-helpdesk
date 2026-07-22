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

## Filas (catálogo real de serviços, v2)

As 4 filas genéricas iniciais (aproximadas a partir de padrões observados nos dados) foram substituídas pelo catálogo real de serviços que o utilizador já usava na plataforma anterior — 14 filas, cada uma mapeada para "Tipo de Pedido" no formulário:

| Fila | Slug | Subtipos (campo "Subtipo", dependente da fila) |
|---|---|---|
| Email | `EMAIL` | Criar endereço, Reset de password, Mensagem de ausência, Configurar app de email, Reencaminhar email |
| Microsoft 365 | `M365` | Licença nova, Reset de password, Configuração, Problema de acesso, Orçamento |
| Alojamento web | `HOST` | Migração, Upgrade de plano, Problema técnico, Configuração DNS, Orçamento |
| Registo de domínio | `DOM` | Novo registo, Transferência, Renovação, Orçamento |
| Certificado SSL | `SSL` | Instalação, Renovação, Problema, Orçamento |
| Criação de site | `SITE` | Novo site, Alterações/actualizações, Erro no site, Orçamento |
| Loja online | `SHOP` | Nova loja, Alterações, Erro, Orçamento |
| Moodle / e-learning | `MOODLE` | Nova instalação, Problema técnico, Utilizadores, Limpeza de espaço, Upgrade SAAS, Upgrade, Orçamento |
| SEO | `SEO` | Novo projecto, Relatório, Ajustes, Orçamento |
| Design gráfico | `DESIGN` | Logo/identidade, Material impresso, Web |
| Marketing digital | `MKT` | Configuração, Relatório, Ajustes, Orçamento |
| Registo de marca | `MARCA` | (sem subtipos) |
| Manutenção / suporte | `SUPORTE` | (sem subtipos) |
| Servidor | `SERVER` | Indisponibilidade, Dificuldade Login |

"Segurança & Alertas" e "Geral" (v1) saíram — decisão do utilizador, para não ter filas que não fazem parte do catálogo real de serviços escolhido pelo cliente.

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

### Por que "Subtipo" é um `CustomField` com JavaScript, e não 60 filas?
60 filas seriam 60 conjuntos de permissões/caixas de correio — infraestrutura a mais para o que é só uma segunda dimensão de classificação. Um `CustomField` "Subtipo" guarda o valor; o JavaScript no formulário só filtra visualmente as opções conforme a fila escolhida (o Django valida no servidor contra a lista completa de valores, independentemente da fila — a coerência categoria↔subtipo é garantida pela interface, não pelo modelo de dados).
