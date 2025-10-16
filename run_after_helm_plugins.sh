#!/usr/bin/env bash

helm plugin install https://github.com/databus23/helm-diff || echo "plugin already installed"

if [[ -f ~/.local/bin/helm ]]
then
  helm plugin update diff && echo "Update successful"
fi
