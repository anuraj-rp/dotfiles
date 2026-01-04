# Load .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# Toggle username display in starship prompt
toggle_username() {
  local config_file="$HOME/.config/starship.toml"
  local temp_file="/tmp/starship.toml.tmp"

  if [ ! -f "$config_file" ]; then
    echo "Error: $config_file not found"
    return 1
  fi

  # Check if username module is disabled
  if sed -n '/^\[username\]/,/^\[/p' "$config_file" | grep -q "disabled = true"; then
    sed '/^\[username\]/,/^\[/ s/disabled = true/disabled = false/' "$config_file" > "$temp_file"
    mv "$temp_file" "$config_file"
    echo "Username shown (reload shell to see changes)"
  elif sed -n '/^\[username\]/,/^\[/p' "$config_file" | grep -q "disabled = false"; then
    sed '/^\[username\]/,/^\[/ s/disabled = false/disabled = true/' "$config_file" > "$temp_file"
    mv "$temp_file" "$config_file"
    echo "Username hidden (reload shell to see changes)"
  else
    echo "Error: Could not find 'disabled' setting in [username] section of $config_file"
    return 1
  fi
}
