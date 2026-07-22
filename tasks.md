# Tasks e Estado do Projecto

## Estado actual — Fase 1 (completa)

| Funcionalidade | Estado |
|---|---|
| Clone completo do repositório upstream (`demodesk/`, `Makefile`, `docs/`) | ✅ |
| `uv` instalado, ambiente virtual criado | ✅ |
| `yarn 4.9.4` resolvido via Corepack (wrapper em `~/.local/bin/yarn`, sem tocar no `pnpm` do Homebrew) | ✅ |
| `make rundemo` — dependências, migrações, fixtures, servidor a correr em `localhost:8080` | ✅ |
| Login `admin` / `Pa33w0rd` confirmado (HTTP 200 em `localhost:8080`) | ✅ |

## Estado actual — Fase 2 (em curso)

### UI — camada de override que sobrevive a updates ✅ IMPLEMENTADO

| Funcionalidade | Estado |
|---|---|
| `STATICFILES_DIRS` a apontar para `demodesk/static_src/` (prioridade sobre `src/helpdesk/static/`) | ✅ |
| `demodesk/static_src/helpdesk/helpdesk-customize.css` — preenche o hook `@import` que já existia em `helpdesk-extend.css` mas nunca tinha ficheiro | ✅ |
| **Regra fixa:** nunca editar `src/helpdesk/`. Templates a mudar visualmente vão para `demodesk/templates/helpdesk/<mesmo caminho>`; CSS vai para `helpdesk-customize.css`. Garante que um update/`git pull` do django-helpdesk nunca colide com as nossas alterações | ✅ |
| Detetado: a app usa **Bootstrap 5.3.8** (não 4 — corrigir se retomarmos os temas Bootswatch) | ✅ registado |

### Primeira melhoria de UI: stat tiles do dashboard ✅ IMPLEMENTADO

| Funcionalidade | Estado |
|---|---|
| Override de `include/stats.html` (os "3 cartões" do dashboard) — de blocos de cor cheia para tiles neutros com selo de estado (`stat-tile__chip`), número em destaque e rótulo em português | ✅ |
| Cores de estado fixas (verde `#0ca30c` / amarelo `#fab219` / vermelho `#d03b3b`) em vez das cores genéricas Bootstrap `success`/`warning`/`danger` | ✅ |
| Verificado: `/dashboard/` carrega o CSS novo sem 404 e a nova estrutura renderiza | ✅ |
| **Nota:** o login não cai no `/dashboard/` por omissão (`login_view_ticketlist=True` leva à lista de tickets) — o dashboard está acessível pelo link "Dashboard" no menu lateral. Avisar se quiserem mudar o destino por omissão do login. | ⚠️ |

### Página pública inicial: sem sidebar, cartões consistentes ✅ IMPLEMENTADO

(Esta era a melhoria que o utilizador queria de facto — confundi inicialmente com o dashboard interno; esclarecido por captura de ecrã da página pública, antes do login.)

| Funcionalidade | Estado |
|---|---|
| Causa raiz encontrada: "Submeter um Ticket" e "Ver um Ticket" usavam classes mortas do Bootstrap 3 (`panel`/`panel-body`, inexistentes no Bootstrap 5) — só por isso é que não pareciam cartões como a coluna da Base de Conhecimento | ✅ diagnosticado |
| Override `demodesk/templates/helpdesk/public_base.html` — barra lateral removida, substituída por uma faixa leve de navegação (Página Inicial / Novo Ticket / Base de Conhecimento / Os Meus Tickets) | ✅ |
| Override `demodesk/templates/helpdesk/public_homepage.html` — `panel`/`panel-body` trocado por `card`/`card-body`, as 3 colunas ficam visualmente iguais | ✅ |
| "Ver um Ticket" mantém-se como página própria (`/view/`), mas herda o layout sem barra lateral do `public_base.html` — resolve a sensação de duplicação sem AJAX (decisão explícita do utilizador, menor esforço) | ✅ |
| `public_view_form.html`, `public_view_ticket.html`, `kb_index.html`, `kb_category.html` — sem alterações directas, herdam a correção automaticamente por estenderem o mesmo `public_base.html` | ✅ |
| Área de staff (`base.html`) mantém a sua barra lateral, intocada | ✅ |
| Verificado: `/`, `/kb/` e `/view/` sem sessão — sem markup de sidebar, faixa de navegação presente, 4 cartões na homepage | ✅ |

### Redesign completo da homepage pública (hero + cartões + marca) ✅ IMPLEMENTADO

| Funcionalidade | Estado |
|---|---|
| Cabeçalho próprio (`public-topbar`) substitui a navbar escura partilhada com o staff — fundo creme, logo real da Webcolinas (`demodesk/static_src/helpdesk/img/logo-250-WH.png`), rótulo "Helpdesk" (o nome já está no logo), navegação e "Iniciar Sessão"/"Terminar Sessão" conforme o estado de login | ✅ |
| Hero (`public-hero`) com "Bem-vindo ao Portal de Suporte" | ✅ |
| Bug corrigido: rodapé "Powered by django-helpdesk" sobrepunha o conteúdo (perda de `padding-bottom` ao remover a sidebar) — removido o rodapé nas páginas públicas e ajustado o espaçamento | ✅ |
| Base de Conhecimento: lista compacta de categorias num só cartão, em vez de um cartão por categoria | ✅ |
| Submeter um Ticket: deixou de embutir o formulário completo na homepage — agora é um cartão simples com botão para `/tickets/submit/` (a página já existente, sem alterações) | ✅ |
| Ver um Ticket: mantém o formulário real (`name="ticket"`, `name="email"`, acção `helpdesk:public_view`), só o visual mudou | ✅ |
| **Funções testadas ponta-a-ponta após o redesign:** `/tickets/submit/` (200), `/kb/` (200), consulta de um ticket real por número+email (`SRV-5` + `teste@example.com`) devolve o ticket correcto | ✅ |

### UI da criação/consulta de ticket ✅ IMPLEMENTADO

| Funcionalidade | Estado |
|---|---|
| Override `public_create_ticket.html` (`/tickets/submit/`) — cartão consistente com a homepage; o formulário em si (`public_create_ticket_base.html`, `{{ form|bootstrap4form }}`) não foi tocado | ✅ |
| Override `public_view_form.html` (`/view/` sem parâmetros, ou depois de uma consulta falhada) — estava em HTML `<dl>` sem estilo nenhum, provavelmente a causa da sensação de "duplicado"/quebrado ao consultar um ticket; agora é um cartão igual aos das outras páginas públicas | ✅ |
| `public_view_ticket.html` (a página que mostra o ticket encontrado) — **não foi reescrita** (é grande e tem lógica de anexos/JS embutida; duplicar o template seria arriscado). Em vez disso, herda as melhorias por CSS: sem sidebar, fundo consistente, botões `btn-primary` a teal, cabeçalhos de tabela em creme | ✅ (CSS only) |
| Testado: submissão de ticket (campos `title`/`queue`/`body`/`priority` intactos), consulta válida (`SRV-5` + email → mostra o ticket), consulta inválida (→ volta ao formulário estilizado, sem erro de servidor) | ✅ |
| **Bug corrigido** — `src/helpdesk/views/public.py`, 2 linhas: `error_message` passava como argumento posicional em vez de nomeado, por isso a mensagem de "ticket/email inválido" nunca aparecia. **Única exceção à regra de não tocar em `src/helpdesk/`** nesta sessão — é correção de bug, não personalização visual; documentado aqui para o caso de um futuro `git pull` gerar conflito nestas 2 linhas | ✅ |
| Formulário de submissão (`public_create_ticket_base.html`, override): intro unificada (removido "Salvo indicação em contrário"), rótulo "Fila"→"Tipo de Pedido", placeholder no resumo ("Tipo de problema — nome da empresa ou domínio"), campo "Data limite" escondido e substituído por nota de SLA (resposta em 48h por email), campo "Canal" escondido e fixado a "Email" — tudo via JS/CSS no template, sem tocar no `Form` Python nem nos nomes dos campos | ✅ |
| **Testado ponta-a-ponta:** ticket real submetido (#9) com os campos escondidos — `due_date=None`, `canal="Email"` gravados corretamente; consulta inválida agora mostra "ID de ticket ou endereço de e-mail inválido. Tente novamente."; consulta válida continua a mostrar o ticket | ✅ |

### Categorias de tickets ✅ IMPLEMENTADO

| Funcionalidade | Estado |
|---|---|
| Fixture `demodesk/fixtures/webcolinas_categories.json` (4 filas + campo "Canal") | ✅ |
| Fixture ligada ao alvo `demo` do `Makefile` | ✅ |
| Fixture carregada na base de dados do demo já em execução | ✅ |
| Documentação (`requirements.md`, `design.md`, `tasks.md`) | ✅ |
| Verificar no browser: novas filas + campo "Canal" no formulário de criação de ticket | ✅ — as 4 filas e o campo "Canal" aparecem no formulário (`/tickets/submit/`) |
| Criar um ticket de teste para validar o fluxo ponta-a-ponta | ✅ — ticket #5 "Teste - servidor em baixo" na fila Servidores & Alojamento, canal Telefone (dados fictícios, pode ser apagado quando quiser) |
| Um ticket de exemplo em cada uma das 4 filas (dados fictícios, sem PII real) | ✅ — #5 Servidores & Alojamento, #6 Email & Microsoft 365, #7 Segurança & Alertas, #8 Geral |

### Catálogo de filas v2: 14 categorias reais + subtipos ✅ IMPLEMENTADO

(Substitui a secção anterior — o utilizador enviou o catálogo real de serviços que já usava noutra plataforma; as 4 filas genéricas e os tickets de exemplo #5-9 foram substituídos.)

| Funcionalidade | Estado |
|---|---|
| `webcolinas_categories.json` reescrito: 14 filas (Email, Microsoft 365, Alojamento web, Registo de domínio, Certificado SSL, Criação de site, Loja online, Moodle/e-learning, SEO, Design gráfico, Marketing digital, Registo de marca, Manutenção/suporte, Servidor) — "Segurança & Alertas" e "Geral" saíram | ✅ |
| Novo `CustomField` "Subtipo" (37 valores únicos, todos os subtipos enviados pelo utilizador, texto exacto) | ✅ |
| `public_create_ticket_base.html`: JavaScript com o mapa fila→subtipos — filtra as opções visíveis do "Subtipo" conforme o "Tipo de Pedido" escolhido; esconde o campo por completo para "Registo de marca"/"Manutenção / suporte" (sem subtipos) | ✅ |
| Listas de subtipos (por fila e a lista principal do campo) postas por ordem alfabética, sem duplicados — confirmado com um teste automatizado num browser real (Playwright), não só por leitura de HTML | ✅ |
| **Formulário interno de staff (`create_ticket.html`, override novo):** mesmo relabel "Fila"→"Tipo de Pedido" e mesmo filtro dependente de "Subtipo" — mas aqui "Canal" e "Data limite" continuam visíveis e editáveis (a equipa precisa de registar o canal real, ex. Telefone, ao criar um ticket em nome de um cliente) | ✅ |
| "Subtipo" movido (via JS, `insertBefore`) para logo a seguir a "Tipo de Pedido" em ambos os formulários, em vez de ficar no fim | ✅ |
| **Testado com Playwright (browser real, com login):** ticket #14 criado no formulário de staff com fila=Email, canal=Telefone, subtipo="Reset de password" — confirma o cenário "cliente liga, equipa cria o ticket em nome dele" | ✅ |
| Tickets de exemplo antigos (#5-9) apagados — ficaram com filas trocadas depois da fixture substituir os pk 3-6 (a fila é `CASCADE`/`loaddata` faz *update*, não *insert*, por isso não desapareceram sozinhos; tiveram de ser removidos à mão) | ✅ |
| 4 novos tickets de teste criados nas filas certas, com subtipo: #10 Email/Reset de password, #11 Servidor/Indisponibilidade, #12 Alojamento web/Configuração DNS, #13 Registo de marca (sem subtipo, confirma que funciona sem um) | ✅ |
| **Nota de arquitetura:** a validação do "Subtipo" no servidor é contra a lista completa de 37 valores, não filtrada por fila — a coerência categoria↔subtipo é garantida só pela interface (JS), não pelo modelo de dados. Documentado em `design.md`. | ✅ |

### Idioma (pt-PT) ✅ IMPLEMENTADO

| Funcionalidade | Estado |
|---|---|
| Interface (`LANGUAGE_CODE = "pt-pt"`) e seletor de idioma (`LocaleMiddleware` + `/i18n/setlang/`) ligados | ✅ — seletor em `/change_language/` |
| 16 templates de e-mail traduzidos para PT-PT (`demodesk/fixtures/pt_emailtemplates.json`) + base de e-mail (`demodesk/templates/helpdesk/pt/`) | ✅ |
| Filas atualizadas para `locale="pt"` (para apanhar os templates de e-mail em PT) | ✅ |
| Tradução completa do catálogo `pt_PT` da interface (`src/helpdesk/locale/pt_PT/`) — vinha 0% traduzido nesta versão (só `pt_BR` vinha completo). O catálogo original também estava desatualizado (faltavam 183 strings); sincronizado via `django-admin makemessages` e traduzido de novo até 100% | ✅ — 695/695 traduzidas, 0 fuzzy, `msgfmt` sem erros |
| Confirmado visualmente (login, dashboard, lista de tickets, formulário de criação) | ✅ |

**Correção adicional:** o Django dava prioridade ao `Accept-Language` do browser sobre o `LANGUAGE_CODE`, por isso browsers em inglês continuavam a ver a interface em inglês apesar do `pt-pt` estar definido. Corrigido com `LANGUAGES = [("pt", "Português")]` em `demodesk/config/settings.py`, que força português independentemente da preferência do browser.

**Limitações conhecidas (não são bugs da tradução, são strings fora do sistema de i18n do Django):**
- `Username`/`Password` no formulário de login estão hardcoded no template (`login.html`), sem `{% trans %}` — nunca traduzem, independentemente do catálogo.
- Alguns cabeçalhos de coluna da lista de tickets (`Priority`, `Queue`, `Status`) vêm definidos no JavaScript do DataTables, não passam pelo sistema de tradução do Django.

## Temas visuais (em pausa)

Explorámos temas Bootswatch (Flatly/Cosmo/Litera/Sandstone) como forma de mudar o visual sem tocar em HTML — só CSS, a estrutura da página não muda. Ficou em pausa a pedido do utilizador para dar prioridade ao idioma e às categorias; retomar quando fizer sentido.

## Backlog — Produção (por confirmar, não iniciado)

- [ ] `SECRET_KEY` via variável de ambiente (hoje hardcoded em `demodesk/config/settings.py`)
- [ ] `DEBUG=False`
- [ ] `ALLOWED_HOSTS` ajustado ao domínio real (hoje vazio)
- [ ] Cookies seguros (`SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`, etc. — hoje comentados no settings do demo)
- [ ] Base de dados de produção (Postgres ou MySQL em vez de SQLite — SQLite não faz pesquisa case-insensitive)
- [ ] Decidir alvo de deployment (standalone Docker vs. integração noutro projecto Django) — ver `docs/standalone.rst` e `docs/install.rst` no repo
- [ ] Configuração de email real (hoje o backend é `console`, só imprime, não envia)
- [ ] Cron/Celery para `get_email` e `escalate_tickets` (ver `docs/configuration.rst`)

## Problemas conhecidos / Confusão comum

### 1. `yarn` global não é o `yarn` do projecto
O projecto fixa `yarn@4.9.4` via `packageManager` no `package.json` (Corepack). O Mac já tinha `pnpm` instalado via Homebrew, por isso não se pode simplesmente `corepack enable` (colide com o shim do `pnpm`). Resolvido com um wrapper `~/.local/bin/yarn` que chama `npx corepack yarn "$@"` — não mexe em nada instalado via Homebrew.

### 2. Node 26 não trai Corepack por omissão
Foi preciso instalar o pacote `corepack` via `npx` em vez de assumir que vinha com o Node.

## Infra / técnico

- Repositório de trabalho: `/Users/hugopereira/Documents/django-helpdesk` (clone git do upstream `django-helpdesk/django-helpdesk`)
- O directório antigo `/Users/hugopereira/Documents/django_helpdesk` (underscore) é só o pacote-fonte (sdist) e não é usado a partir daqui
- Referência de categorias: `/Users/hugopereira/Documents/Webcolinas-Manager` (só leitura, nenhum dado copiado)
