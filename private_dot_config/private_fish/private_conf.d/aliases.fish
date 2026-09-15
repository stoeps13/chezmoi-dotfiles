# Make alias for vim to neovim (save muscle memory in ssh and server sessions)
function vim
    nvim $argv
end

# ── Functions (can't be aliases) ──────────────────────────────────────────────

function fix
    git diff --name-only | uniq | xargs $EDITOR
end

function tpane
    tmux rename-window (echo $hostname | awk -F '.' '{print $1}')
end

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	command rm -f -- "$tmp"
end

# TaskWarrior Fish aliases and functions

# --- Quick Add Aliases ------------------------------------------------------
alias t='task'
alias ta='task add'
alias tl='task next'
alias td='task done'
alias tm='task modify'
alias ts='task sync'
alias tde='task delete'
alias tan='task annotate'

# --- Report Aliases ---------------------------------------------------------
alias tin='task inbox'          # Triage inbox
alias tto='task today'          # Today's focus
alias tsu='task standup'        # Standup report
alias tre='task review'         # Weekly review
alias tbl='task blockers'       # Blocked tasks
alias tw='task waiting'         # Waiting tasks
alias tc='task calendar'        # Calendar view
alias tbu='task burndown.daily' # Burndown chart
alias tal='task all'

# --- Context Switching ------------------------------------------------------
alias tcb='task context Bosch'
alias tcv='task context Vegard'
alias tcp='task context Personal'
alias tca='task context Atruvia'
alias tci='task context Inbox'
alias tcn='task context none'


# --- Workflow Functions -----------------------------------------------------

# Quick capture: tq "buy groceries" => adds to inbox
function tq
    task add +inbox $argv
    echo "Captured to inbox."
end

# Start working on a task
function tw_start
    task "$argv[1]" start
    task "$argv[1]" modify +next
end

# Finish a task (stop + done)
function tw_finish
    task "$argv[1]" stop 2>/dev/null
    task "$argv[1]" done
end

# Defer a task to a future date
function tw_defer
    set -l id $argv[1]
    set -l date tomorrow
    if test (count $argv) -ge 2
        set date $argv[2]
    end
    task "$id" modify wait:"$date" scheduled:"$date"
    echo "Task $id deferred until $date"
end

# Morning routine: show today's tasks + overdue
function tw_morning
    echo "=== Overdue ==="
    task overdue 2>/dev/null || echo "  None!"
    echo ""
    echo "=== Today ==="
    task today 2>/dev/null || echo "  Nothing scheduled."
    echo ""
    echo "=== Active ==="
    task active 2>/dev/null || echo "  Nothing active."
end

# Weekly review helper
function tw_weekly
    echo "=== Completed This Week ==="
    task end.after:today-7d completed
    echo ""
    echo "=== All Open Tasks ==="
    task review
    echo ""
    echo "=== Inbox (needs triage) ==="
    task inbox 2>/dev/null || echo "  Inbox empty!"
end

# Add a task with common project patterns
function tw_work
    task add +work project:"$argv[1]" $argv[2..-1]
end

function tw_personal
    task add +personal project:"$argv[1]" $argv[2..-1]
end

# Task stats summary
function tw_stats
    echo "=== Task Stats ==="
    task stats
    echo ""
    echo "=== Projects ==="
    task projects
    echo ""
    echo "=== Tags ==="
    task tags
end
