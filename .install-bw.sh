#!/bin/sh

type bw >/dev/null 2>&1 && exit

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
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
