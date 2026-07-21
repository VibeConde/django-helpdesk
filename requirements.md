# Requisitos do Produto

## Visão

Sistema de tickets operacional (django-helpdesk) para gerir os pedidos de suporte da equipa — email, telefone e WhatsApp — num único local, com filas por área de trabalho e histórico de cada pedido.

**Origem:** este projecto nasce do checkout local do django-helpdesk (upstream, `django-helpdesk/django-helpdesk`), posto a correr como demo, e evolui a partir daqui para uso real pela equipa. A estrutura de categorias reutiliza o que já foi aprendido a operar suporte no Webcolinas-Manager (módulo `Request`), sem herdar o código nem os dados desse projecto.

## Princípios

- Não duplicar trabalho: usar sempre os mecanismos que o django-helpdesk já suporta (filas, campos custom, fixtures) em vez de código novo.
- Não tocar em nada relacionado com segurança/autenticação só para "customizar" — customização é aditiva, não substitui o que já existe.
- Dados de clientes reais (da Webcolinas-Manager ou de qualquer outra fonte) não entram neste sistema sem decisão explícita caso a caso.

## Utilizadores alvo

- **Staff/agentes** — criam, respondem e fecham tickets; têm acesso às filas conforme permissão.
- **Submissores** (via formulário público ou email) — abrem pedidos, acompanham o estado, sem acesso ao painel de staff.

## Requisitos funcionais

### Ambiente de demo/desenvolvimento
- [x] Clone completo do repositório upstream (com `demodesk/`, `Makefile`, `docs/`)
- [x] `make rundemo` funcional de raiz a servidor a correr (`uv`, `yarn` via Corepack, migrações, fixtures)
- [x] Login `admin` / `Pa33w0rd` a funcionar em `http://localhost:8080`

### Categorias de tickets (filas)
- [x] Fila "Servidores & Alojamento" — logins, indisponibilidade, criação de contas de alojamento
- [x] Fila "Email & Microsoft 365"
- [x] Fila "Segurança & Alertas" — alertas automáticos (ex. Wordfence) e incidentes de segurança
- [x] Fila "Geral" — tudo o que não encaixa nas anteriores (Moodle/e-learning, novas plataformas, etc.)
- [x] Campo custom "Canal" (Email / Telefone / WhatsApp / Outro) em cada ticket

### Fluxo de tickets
- [ ] Confirmar mapeamento de estados a usar (ver `design.md`) e ajustar `HELPDESK_TICKET_STATUS_CHOICES` só se necessário
- [ ] Criar os primeiros tickets reais nas filas já preparadas

## Requisitos não-funcionais

### Segurança
- Autenticação, permissões por fila, CSRF, validação de anexos e validadores de password do Django **não são alterados** por este trabalho.
- Qualquer customização feita (filas, campos custom) usa apenas os mecanismos de extensão já suportados pelo django-helpdesk — nada de código a contornar verificações existentes.
- Import de dados de outra aplicação está **fora de âmbito** (ver secção abaixo) precisamente para não introduzir dados de terceiros sem controlo.

### Manutenibilidade
- Toda a estrutura de categorias vive numa fixture (`demodesk/fixtures/webcolinas_categories.json`), carregada como as restantes (`demo.json`, `emailtemplate.json`) — sem management commands nem apps novas só para isto.

### Observabilidade
- Sem requisitos adicionais para já; o logging por fila já suportado pelo django-helpdesk (`Queue.logging_type`) fica disponível se e quando for preciso.

## Fora de âmbito (intencional)

- **Importar os pedidos reais do Webcolinas-Manager** — decisão explícita do utilizador: os 36 pedidos existentes ficam onde estão; só a estrutura de categorias foi replicada, nunca os dados de clientes (domínios, contactos, alertas).
- **Deployment de produção** (secret key via env, `DEBUG=False`, `ALLOWED_HOSTS`, cookies seguros, base de dados Postgres/MySQL, domínio/TLS) — fica documentado como backlog em `tasks.md`, a decidir e executar numa fase à parte.
