function load_secrets
    if test -f "$HOME/.config/fish/conf.d/secrets.yaml"
      sops -d --output-type json "$HOME/.config/fish/conf.d/secrets.yaml"| jq -r 'to_entries | .[] | "set -gx \(.key) \(.value)"'| source
    else
      echo "Secrets file not found: $HOME/.config/fish/conf.d/secrets.yaml"
    end
end
  
