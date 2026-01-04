# Toggle username display in starship prompt
toggle_username() {
  local config_file="$HOME/.config/starship.toml"

  if [ ! -f "$config_file" ]; then
    echo "Error: $config_file not found"
    return 1
  fi

  if grep -q "show_always = true" "$config_file"; then
    sed -i 's/show_always = true/show_always = false/' "$config_file"
    echo "Username hidden (reload shell to see changes)"
  elif grep -q "show_always = false" "$config_file"; then
    sed -i 's/show_always = false/show_always = true/' "$config_file"
    echo "Username shown (reload shell to see changes)"
  else
    echo "Error: Could not find 'show_always' setting in $config_file"
    return 1
  fi
}
