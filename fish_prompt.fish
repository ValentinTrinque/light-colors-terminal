set prompt_red "#E11D48"
set prompt_brred "#FFE4E6"
set prompt_green "#059669"
set prompt_brgreen "#D1FAE5"
set prompt_yellow "#EA580C"
set prompt_bryellow "#FFEDD5"
set prompt_blue "#0284C7"
set prompt_brblue "#E0F2FE"
set prompt_magenta "#DB2777"
set prompt_brmagenta "#FCE7F3"
set prompt_cyan "#0891B2"
set prompt_brcyan "#CFFAFE"
set prompt_white "#4B5563"
set prompt_brwhite "#F3F4F6"

function fish_prompt --description 'Informative prompt'

    # Save the return status of the previous command
    set -l last_pipestatus $pipestatus

    if set -l git_branch (command git symbolic-ref HEAD 2>/dev/null | string replace refs/heads/ '')
        
        # Count commit tree diff
        set -l upstream (command git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
    
        if test "$upstream" != "" && test "$upstream" != "@{u}"
            command git rev-list --count --left-right $upstream...HEAD 2>/dev/null | read -l commit_behind commit_ahead
            if test "$commit_ahead" -gt 0
                set git_status "$git_status"↑"$commit_ahead "
            end

            if test "$commit_behind" -gt 0
                set git_status "$git_status"↓"$commit_behind "
            end
        end

        # Count dirty files    
        set -l dirty_files_count (command git status --porcelain | wc -l | awk '{print $1}')
        if test "$dirty_files_count" -gt 0
            set git_status "$git_status"✖"$dirty_files_count "
        end 

        if test "$git_status" != ""
            set git_status (set_color -o $prompt_yellow)" $git_status"
        end
        
        set git_info (set_color -o $prompt_green)" ⌥ $git_branch $git_status"(set_color normal)(set_color -b normal)
    end

   
    switch "$USER"
        case root toor
            printf '%s %s%s%s # ' $USER \
                (set -q fish_color_cwd_root and set_color $fish_color_cwd_root or set_color $fish_color_cwd) \
                (prompt_p wd) (set_color normal)
        case '*'
            set -l pipestatus_string (__print_pipestatus $last_pipestatus)
            set -l xtime (set_color -o $prompt_white)(date "+%H:%M:%S")" "(set_color normal)(set_color -b normal)
            set -l path (set_color -o $prompt_blue)" "(__print_pwd)" "(set_color normal)(set_color -b normal)
            set -l cmd (set_color -o $prompt_yellow)"❯❯❯"(set_color normal)(set_color -b normal)" "

            printf "\n\n$xtime$path$git_info $pipestatus_string \n$cmd%s"
    end

end

function __print_pipestatus --description "Print pipestatus for prompt"
    set -l last_status
    if set -q __fish_last_status
        set last_status $__fish_last_status
    else
        set last_status $argv[1] # default to $pipestatus[-1]
    end

    # Only print status codes if the job failed.
    # SIGPIPE (141 = 128 + 13) is usually not a failure, see #6375.
    if not contains $last_status 0 141
        set -l last_pipestatus_string (__fish_status_to_signal $argv | string join "|")
        set -l last_status_string ""
        if test "$last_status" -ne "$argv[1]"
            set last_status_string " "$last_status
        end
        echo (set_color -o $prompt_red)" ["$last_pipestatus_string$last_status_string"] "(set_color normal)(set_color -b normal)
    end
end

function __print_pwd --description 'Print the current working directory, NOT shortened to fit the prompt'
    if test "$PWD" != "$HOME"
        echo $PWD | sed -e "s|^$HOME|~|"
    else
        echo '~'
    end

end