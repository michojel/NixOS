def fzf-history [
    --query (-q): string # Optionally start with given query.
] {
    let cmd = (history | uniq | reverse | each { echo [$it (char nl)] } | str collect | fzf --query $"($query)")
    xdotool type $cmd
}

alias R = fzf-history
alias Rq = fzf-history -q
alias mux = tmuxinator

let $config = {
    keybindings: [
      {
        name: "fzf"
        modifier: "control"
        keycode: "char_f"
        mode: "vi"
        event: [
          { edit: { cmd: clear } }
          { edit: { cmd: insertString value: "fzf-history" } }
          { send: enter }
        ]
      }

      {
        name: "fzf_emacs"
        modifier: "control"
        keycode: "char_f"
        mode: "emacs"
        event: [
          { edit: { cmd: clear } }
          { edit: { cmd: insertString value: "fzf-history" } }
          { send: enter }
        ]
      }

      {
        name: "change_dir_with_fzf"
        modifier: "control"
        keycode: "char_t"
        mode: "emacs"
        event: {
          send: executehostcommand,
          cmd: "cd (ls | where type == dir | each { |it| $it.name} | str collect (char nl) | fzf | decode utf-8 | str trim)"
        }
      }
    ]
}
