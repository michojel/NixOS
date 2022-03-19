# recognice ** patterns
shopt -s globstar

if [[ -f ~/.bash_prompt ]]; then
    # shellcheck disable=SC1090
    source ~/.bash_prompt || :
fi
