#!/bin/sh

# exit immediately if password-manager-binary is already in $PATH
type password-manager-binary >/dev/null 2>&1 && exit

case "$(uname -s)" in
Linux)
    if [ ! -f ~/.local/bin/bw ];
    then
      dir=$(mktemp -d)
      curl --location --output $dir/bw-cli.zip 'https://vault.bitwarden.com/download/?app=cli&platform=linux'
      unzip -d $dir/bw $dir/bw-cli.zip
      if [ ! -d ~/.local/bin ];
      then
        mkdir -p ~/.local/bin
      fi
      mv $dir/bw/bw ~/.local/bin/
      chmod +x ~/.local/bin/bw
      rm -rf $dir
    fi
    bw login christoph.stoettner@stoeps.de --method 2
    pause
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
