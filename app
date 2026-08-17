#!/usr/bin/env bash
#
# Liga/desliga o servidor de desenvolvimento do django-helpdesk.
#
#   ./app start     arranca em background (porto 8080)
#   ./app stop      desliga
#   ./app restart   reinicia
#   ./app status    mostra se está a correr
#   ./app logs      segue o log (Ctrl-C para sair)
#
# O porto pode ser mudado com a variável PORT: PORT=9000 ./app start

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

PORT="${PORT:-8080}"
RUN_DIR="$ROOT/.run"
PID_FILE="$RUN_DIR/app.pid"
LOG_FILE="$RUN_DIR/app.log"

mkdir -p "$RUN_DIR"

running_pid() {
	[ -f "$PID_FILE" ] || return 1
	local pid
	pid="$(cat "$PID_FILE")"
	[ -n "$pid" ] || return 1
	kill -0 "$pid" 2>/dev/null || return 1
	echo "$pid"
}

start() {
	local pid
	if pid="$(running_pid)"; then
		echo "Já está a correr (PID $pid) em http://localhost:$PORT"
		return 0
	fi

	if [ ! -f "$ROOT/demodesk/db.sqlite3" ]; then
		echo "Base de dados não encontrada. Corre primeiro:  make demo"
		return 1
	fi

	nohup uv run manage.py runserver "$PORT" >"$LOG_FILE" 2>&1 &
	echo $! >"$PID_FILE"

	# Espera que o servidor comece a responder (até ~20s).
	local i
	for i in $(seq 1 40); do
		if curl -s -o /dev/null "http://127.0.0.1:$PORT/"; then
			echo "A correr em http://localhost:$PORT  (PID $(cat "$PID_FILE"))"
			echo "Login: admin / Pa33w0rd"
			return 0
		fi
		if ! running_pid >/dev/null; then
			echo "O arranque falhou. Últimas linhas do log:"
			tail -20 "$LOG_FILE"
			rm -f "$PID_FILE"
			return 1
		fi
		sleep 0.5
	done

	echo "O servidor arrancou mas não respondeu a tempo. Vê o log: ./app logs"
	return 1
}

stop() {
	local pid
	if ! pid="$(running_pid)"; then
		# Pode ter ficado um processo órfão de um arranque anterior.
		if pkill -f "manage.py runserver $PORT" 2>/dev/null; then
			echo "Processos órfãos terminados."
		else
			echo "Não está a correr."
		fi
		rm -f "$PID_FILE"
		return 0
	fi

	# O autoreload do Django corre num processo filho: mata os dois.
	pkill -P "$pid" 2>/dev/null || true
	kill "$pid" 2>/dev/null || true

	local i
	for i in $(seq 1 20); do
		running_pid >/dev/null || break
		sleep 0.25
	done

	if running_pid >/dev/null; then
		pkill -P "$pid" -9 2>/dev/null || true
		kill -9 "$pid" 2>/dev/null || true
	fi

	pkill -f "manage.py runserver $PORT" 2>/dev/null || true
	rm -f "$PID_FILE"
	echo "Desligado."
}

status() {
	local pid
	if pid="$(running_pid)"; then
		echo "A correr (PID $pid) em http://localhost:$PORT"
	else
		echo "Parado."
		return 1
	fi
}

case "${1:-start}" in
start) start ;;
stop) stop ;;
restart)
	stop
	start
	;;
status) status ;;
logs) tail -f "$LOG_FILE" ;;
*)
	echo "Uso: ./app {start|stop|restart|status|logs}"
	exit 1
	;;
esac
