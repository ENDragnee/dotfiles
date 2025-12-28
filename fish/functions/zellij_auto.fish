function zellij_auto
  if set -q ZELLIJ
        return
    end

    set sessions (zellij list-sessions 2>/dev/null)

    if contains Main $sessions
        echo "Zellij session 'Main' exists."
        echo "Available Zellij sessions:"
        for session in $sessions
            echo $session
        end
        read -l -p "Session name to attach: " selected_session
        zellij attach $selected_session
    else
        echo "Zellij session 'Main' does not exist. Creating and attaching..."
        zellij attach --create Main
    end
end
