#!/bin/sh

# exit immediately if password-manager-binary is already in $PATH
type password-manager-binary >/dev/null 2>&1 && exit

case "$(uname -s)" in
Linux)
    if [ ! -f ~/.local/bin/bw ];
    then
      curl --location --output /tmp/bw-cli.zip 'https://vault.bitwarden.com/download/?app=cli&platform=linux'
      unzip -d /tmp/bw /tmp/bw-cli.zip
      if [ ! -d ~/.local/bin ];
      then
        mkdir -p ~/.local/bin
      fi
      mv /tmp/bw/bw ~/.local/bin/
      chmod +x ~/.local/bin/bw
      rm -rf /tmp/bw /tmp/bw-cli.zip
    fi
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
