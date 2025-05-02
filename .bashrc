# Pretty print prompt to allow developers to know that they are using
# the shell in the container

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

hostname='uv-python'
blue=$(tput setaf 4)
green=$(tput setaf 2)
red=$(tput setaf 1)
reset=$(tput sgr0)
bold=$(tput bold)
export PS1="${blue}\u@${hostname}-\h ${green}${bold}\w \[$red\]\$(parse_git_branch)${reset}$ "

# Pyenv
export PYENV_ROOT="${HOME}/.pyenv"
[[ -d "${PYENV_ROOT}/bin" ]] && export PATH="${PYENV_ROOT}/bin:${PATH}"
eval "$(pyenv init -)"

# UV
export PATH="${HOME}/.local/bin/:${PATH}"

