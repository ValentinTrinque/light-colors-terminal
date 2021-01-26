function fish_prompt --description 'Informative prompt'

    # Save the return status of the previous command
    set -l last_pipestatus $pipestatus

    if set -l git_branch (command git symbolic-ref HEAD 2>/dev/null | string replace refs/heads/ '')
        
        # Count commit tree diff
        set -l upstream (command git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null)
    
        if test "$upstream" != ""
            command git rev-list --count --left-right $upstream...HEAD 2>/dev/null | read -l commit_ahead commit_behind
            if test "$commit_ahead" -gt 0
                set git_status "$git_status"↑"$ahead "
            end

            if test "$commit_behind" -gt 0
                set git_status "$git_status"↓"$behind "
            end
        end

        # Count dirty files    
        set -l dirty_files_count (command git status --porcelain | wc -l | awk '{print $1}')
        if test "$dirty_files_count" -gt 0
            set git_status "$git_status"✖"$dirty_files_count "
        end 

        if test "$git_status" != ""
            set git_status (set_color yellow)(set_color -b bryellow)" $git_status"
        end
        
        set git_info (set_color green)(set_color -b brgreen)" ⌥ $git_branch $git_status"(set_color normal)(set_color -b normal)
    end

   
    switch "$USER"
        case root toor
            printf '%s %s%s%s # ' $USER \
                (set -q fish_color_cwd_root and set_color $fish_color_cwd_root or set_color $fish_color_cwd) \
                (prompt_p wd) (set_color normal)
        case '*'
            set -l pipestatus_string (__print_pipestatus $last_pipestatus)
            set -l xtime (set_color white)(set_color -b brwhite)" "(date "+%H:%M:%S")" "(set_color normal)(set_color -b normal)
            set -l path (set_color blue)(set_color -b brblue)" "(__print_pwd)" "(set_color normal)(set_color -b normal)
            set -l cmd (set_color -b normal)(set_color bryellow)"❯❯❯"(set_color normal)(set_color -b normal)" "

            printf "\n\n$fish_git_prompt$xtime$path$git_info $pipestatus_string \n$cmd%s"
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
        echo (set_color red)(set_color -b brred)" ["$last_pipestatus_string$last_status_string"] "(set_color normal)(set_color -b normal)
    end
end

function __print_pwd --description 'Print the current working directory, NOT shortened to fit the prompt'
    if test "$PWD" != "$HOME"
        echo $PWD | sed -e "s|^$HOME|~|"
    else
        echo '~'
    end

end