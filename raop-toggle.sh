#!/bin/bash
# raop-toggle.sh — Start or stop PipeWire RAOP (AirPlay) discovery

CONFIG_FILE="$HOME/.config/pipewire/pipewire.conf.d/raop-discover.conf"

restart_audio() {
    systemctl --user restart pipewire pipewire-pulse wireplumber
    echo "Audio services restarted."
}

case "${1:-}" in
    start)
        if [[ -f "$CONFIG_FILE" ]]; then
            echo "RAOP discovery already enabled."
        else
            mkdir -p "$(dirname "$CONFIG_FILE")"
            cat > "$CONFIG_FILE" << 'EOF'
context.modules = [
    {
        name = libpipewire-module-raop-discover
        args = { }
    }
]
EOF
            echo "RAOP discovery enabled."
            restart_audio
        fi
        ;;
    stop)
        if [[ ! -f "$CONFIG_FILE" ]]; then
            echo "RAOP discovery already disabled."
        else
            rm "$CONFIG_FILE"
            echo "RAOP discovery disabled."
            restart_audio
        fi
        ;;
    status)
        if [[ -f "$CONFIG_FILE" ]]; then
            echo "RAOP discovery: enabled"
        else
            echo "RAOP discovery: disabled"
        fi
        ;;
    help|-h|--help)
        echo "Usage: $(basename "$0") {start|stop|status|help}"
        echo ""
        echo "Commands:"
        echo "  start   Enable RAOP (AirPlay) discovery and restart audio services"
        echo "  stop    Disable RAOP discovery and restart audio services"
        echo "  status  Show whether RAOP discovery is currently enabled"
        echo "  help    Show this help message"
        ;;
    *)
        echo "Usage: $(basename "$0") {start|stop|status|help}"
        exit 1
        ;;
esac
