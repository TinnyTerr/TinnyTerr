#!/bin/bash

# Separators
soft_sep='';
hard_sep='';

# Colors
reset='\[\033[0m\]';
bold='\[\033[1m\]';

# Customize colors here (using ANSI escape codes)
txt='\[\033[38;5;219m\]';             # Light Pink Text
txt_prf='\[\033[38;5;219m\]';         # Light Pink Prompt
user_bg='\[\033[48;5;90m\]';          # Medium Purple Background
root_bg='\[\033[48;5;90m\]';          # Medium Purple Background for root
host_colour='\[\033[48;5;165m\033[38;5;219m\]';  # Pink Host
host_sepc='\[\033[38;5;165m\]';       # Pink Host Separator
user_colour='\[\033[1;48;5;90m\]'$txt; # User color
user_sepc='\[\033[48;5;133m\033[38;5;90m\]'; # User separator color
root_colour='\[\033[1;48;5;125m\]'$txt; # Darker Pink for root
root_sepc='\[\033[48;5;133m\033[38;5;125m\]'; # Root separator color
git_clean_colour='\[\033[48;5;105m\]'; # Git clean color (Purplish)
git_clean_sepc='\[\033[38;5;105m\]';   # Git clean separator color
git_needs_commit_colour='\[\033[48;5;197m\]'; # Git needs commit color (Bright Pink)
git_needs_commit_sepc='\[\033[38;5;197m\]';   # Git needs commit separator color
path_colour='\[\033[0m\]'$user_sepc$txt;  # Path color
cdir_sep=$reset'\[\033[38;5;133m\]';   # Directory separator
pwd_sepc='\[\033[38;5;133m\]';         # PWD separator color

# Adjust colors based on user
if [ $(id -u) == 0 ]; then
    user_bg=$root_bg;
    user_colour=$root_colour;
    user_sepc=$root_sepc;
fi

# Function to generate the prompt
function __generate_ps1 {
    local prompt='';
    if [ "$SSH_CONNECTION" ]; then
        prompt+=$host_colour'  \h '$host_sepc$user_bg$hard_sep;
    fi

    prompt+=$user_colour' \u '"$user_sepc$hard_sep $path_colour";
    local git=$(git rev-parse --show-toplevel 2> /dev/null);
    local parts;
    local pwd=$(pwd);
    local path=${pwd/$HOME/\~};
    local git_colour=$git_clean_colour;
    local git_sepc=$git_clean_sepc;

    if [ $path == "/" ] || [ $path == "~" ]; then
        prompt+="$bold$path $reset$pwd_sepc$hard_sep$reset";
        export PS1=$prompt' ';
        return 0;
    fi

    if [[ "$git" ]]; then
        echo git status | grep "nothing to commit" > /dev/null 2>&1;
        if [[ "$?" != "0" ]]; then
            git_colour=$git_needs_commit_colour;
            git_sepc=$git_needs_commit_sepc;
        fi

        if [[ $git == '.' ]]; then
            path='';
            IFS='/' read -a parts <<< "${pwd/$HOME/\~}";
        else
            path=${pwd/$git};
            IFS='/' read -a parts <<< "${git/$HOME/\~}";
        fi

        local prnt=${parts[${#parts[@]}-2]};
        if [[ "$prnt" == "~" ]]; then
            prompt+="~ $soft_sep ";
        elif [[ "$prnt" ]]; then
            prompt+="… $soft_sep ";
        fi

        local branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null);
        prompt+="${parts[${#parts[@]}-1]} $git_colour$pwd_sepc$hard_sep$txt";
        prompt+="  $bold${branch/HEAD/master} $reset$git_colour";
    fi
    IFS='/' read -a parts <<< "$path";

    if [[ "$path" != '' ]]; then
        if [[ "$git" == '' ]]; then
            if [[ "${parts[2]}" ]] && [[ "${parts[3]}" ]]; then
                prompt+="… $soft_sep ";
            elif [[ "${parts[2]}" ]] && ( [[ "$path" == /* ]] || [[ "$path" == ~* ]] ); then
                prompt+="${path:0:1} $soft_sep ";
            elif [[ "$path" == /* ]]; then
                prompt+="/ $soft_sep ";
            fi
        else
            prompt+="$soft_sep ";
        fi
        [[ ${parts[${#parts[@]}-2]} ]] && prompt+="${parts[${#parts[@]}-2]} $soft_sep ";
        prompt+=$bold${parts[${#parts[@]}-1]}' ';
    fi

    if [[ $git ]]; then
        prompt+=$reset$git_sepc$hard_sep$reset;
    else
        prompt+=$reset$pwd_sepc$hard_sep$reset;
    fi

    prompt+=$reset' ';
    export PS1=$prompt;
}
export -f __generate_ps1
export PROMPT_COMMAND='__generate_ps1';

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
