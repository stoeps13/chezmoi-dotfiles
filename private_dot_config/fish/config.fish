if status is-interactive
    # Commands to run in interactive sessions can go here
end
direnv hook fish | source

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/stoeps/.lmstudio/bin
# End of LM Studio CLI section


# opencode
fish_add_path /home/stoeps/.opencode/bin
