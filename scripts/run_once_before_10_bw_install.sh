#!/bin/sh

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
    export BW_SESSION=$(bw login christoph.stoettner@stoeps.de --method 2 --raw)
    ;;
*)
    echo "unsupported OS"
    exit 1
    ;;
esac
