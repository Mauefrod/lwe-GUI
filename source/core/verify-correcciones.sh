#!/bin/bash
# verify-correcciones.sh - Verifica que todas las correcciones estén aplicadas correctamente

echo "========== VERIFICACIÓN DE CORRECCIONES =========="
echo ""

ERRORS=0
WARNINGS=0

# Función para imprimir resultado
check() {
    local topic="$1"
    local expected="$2"
    local file="$3"
    
    if grep -q "$expected" "$file" 2>/dev/null; then
        echo "✓ $topic"
        return 0
    else
        echo "✗ $topic"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

check_file_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo "✓ Archivo existe: $file"
        return 0
    else
        echo "✗ Archivo NO existe: $file"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

echo "[1] Verificando main.sh..."
check_file_exists "source/core/main.sh"
check "  - cmd_stop con [STOP] logging" '\[STOP\] Attempting to kill' "source/core/main.sh"
check "  - kill_by_pattern con TERM/KILL" 'kill_by_pattern.*TERM' "source/core/main.sh"
check "  - Message con killed.*process group" 'killed.*process group' "source/core/main.sh"
echo ""

echo "[2] Verificando bash_utils.sh..."
check_file_exists "source/core/bash_utils.sh"
check "  - Mapeo TERM a 15" 'TERM.*signal_num.*15' "source/core/bash_utils.sh"
check "  - Mapeo KILL a 9" 'KILL.*signal_num.*9' "source/core/bash_utils.sh"
check "  - Función list_matching_processes" 'list_matching_processes' "source/core/bash_utils.sh"
check "  - kill_by_pattern con logging mejorado" 'Found.*process.*matching' "source/core/bash_utils.sh"
echo ""

echo "[3] Verificando run.sh..."
check_file_exists "source/run.sh"
check "  - ROOT_DIR con dirname SCRIPT_DIR" 'dirname.*SCRIPT_DIR' "source/run.sh"
echo ""

echo "[4] Verificando async-window-fixer.sh..."
check_file_exists "source/core/async-window-fixer.sh"
check "  - Sintaxis bash corregida" 'local -a windows' "source/core/async-window-fixer.sh"
echo ""

echo "[5] Verificando debug-processes.sh..."
check_file_exists "source/core/debug-processes.sh"
check "  - Script de debug existe" 'LINUX WALLPAPER ENGINE.*PROCESS DEBUG' "source/core/debug-processes.sh"
echo ""

echo "[6] Estado de procesos..."
echo "  Procesos bash.*main.sh: $(pgrep -f 'bash.*main.sh' | wc -l)"
echo "  Procesos linux-wallpaperengine: $(pgrep -f 'linux-wallpaperengine' | wc -l)"
echo "  Procesos window-monitor: $(pgrep -f 'window-monitor.sh' | wc -l)"
echo ""

echo "========== RESUMEN =========="
if [[ $ERRORS -eq 0 ]]; then
    echo "✓ Todas las correcciones están aplicadas correctamente"
    exit 0
else
    echo "✗ Se encontraron $ERRORS error(es)"
    exit 1
fi
