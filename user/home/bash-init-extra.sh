# shellcheck disable=SC2016

HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S: "

# TODO: fix
#bind -m emacs-standard '"\C-r": " \C-e\C-u$(HISTTIMEFORMAT=\"%Y/%m/%d %H:%M:%S:   \" history | fzf +s +m -x -n..,1,2,3,4.. | sed \"s/ *[0-9]* *//\")\e\C-e\er"'
#bind -m vi-command     '"\C-r": "\C-z\C-r\C-z"'
#bind -m vi-insert      '"\C-r": "\C-z\C-r\C-z"'

PROMPT_COMMAND="history -a;${PROMPT_COMMAND:-}"

# inspired by https://stackoverflow.com/a/37007733

function is_in_git_repo() {
    git rev-parse HEAD > /dev/null 2>&1
}

function gF() {
    is_in_git_repo &&
        git -c color.status=always status --short | \
            fzf --height 40% -m --ansi --nth 2..,.. | awk '{print $2}'
}

function gB() {
    is_in_git_repo &&
        git branch -a -vv --color=always | grep -v '/HEAD\s' | \
            fzf --height 40% --ansi --multi --tac | sed 's/^..//' | awk '{print $1}' | \
            sed 's#^remotes/[^/]*/##'
}

function gT() {
    is_in_git_repo &&
        git tag --sort -version:refname | fzf --height 40% --multi
}

function gH() {
    is_in_git_repo &&
        git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph | \
        fzf --height 40% --ansi --no-sort --reverse --multi | grep -o '[a-f0-9]\{7,\}'
}

function gR() {
    is_in_git_repo &&
        git remote -v | awk '{print $1 " " $2}' | uniq | \
            fzf --height 40% --tac | awk '{print $1}'
}

# bind '"\er": redraw-current-line'  # part of fzf-keybindings already
# complete branches - in tmux we cannot bin \C-b, therefor \C-v (as "Větev")
bind -m emacs-standard '"\C-g\C-v": "$(gB)\e\C-e\er"'
bind -m vi-command     '"\C-g\C-v": "\C-z\C-g\C-v\C-z"'
bind -m vi-insert      '"\C-g\C-v": "\C-z\C-g\C-v\C-z"'
# complete untracked/modified
bind -m emacs-standard '"\C-g\C-f": "$(gF)\e\C-e\er"'
bind -m vi-command     '"\C-g\C-f": "\C-z\C-g\C-f\C-z"'
bind -m vi-insert      '"\C-g\C-f": "\C-z\C-g\C-f\C-z"'
# complete tags
bind -m emacs-standard '"\C-g\C-t": "$(gT)\e\C-e\er"'
bind -m vi-command     '"\C-g\C-t": "\C-z\C-g\C-t\C-z"'
bind -m vi-insert      '"\C-g\C-t": "\C-z\C-g\C-t\C-z"'
# complete history/log/commits
bind -m emacs-standard '"\C-g\C-h": "$(gH)\e\C-e\er"'
bind -m vi-command     '"\C-g\C-h": "\C-z\C-g\C-h\C-z"'
bind -m vi-insert      '"\C-g\C-h": "\C-z\C-g\C-h\C-z"'
# complete remotes
bind -m emacs-standard '"\C-g\C-r": "$(gR)\e\C-e\er"'
bind -m vi-command     '"\C-g\C-r": "\C-z\C-g\C-r\C-z"'
bind -m vi-insert      '"\C-g\C-r": "\C-z\C-g\C-r\C-z"'

# ex: et ts=4 sw=4 :
