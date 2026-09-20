function bw-env
    if not set -q BW_SESSION
        set -l master_password (secret-tool lookup service bw-env username $USER 2>/dev/null)

        if test -n "$master_password"
            set -gx BW_SESSION (env BW_MASTER_PASSWORD="$master_password" bw unlock --passwordenv BW_MASTER_PASSWORD --raw)
        else
            echo "Bitwarden is locked; enter your master password." >&2
            set -gx BW_SESSION (bw unlock --raw)
        end

        or return 1
    end

    set -l search (string join ' ' -- $argv)
    set -l keys (bw get username "$search")
    or return 1

    set -l values (bw get password "$search")
    or return 1

    set -l key_list (string split ' ' -- $keys)
    set -l value_list (string split ' ' -- $values)
    set -l last_value

    for i in (seq (count $key_list))
        if test $i -le (count $value_list)
            set last_value $value_list[$i]
        end

        set -gx $key_list[$i] $last_value
        echo "Loaded $key_list[$i]" >&2
    end
end
