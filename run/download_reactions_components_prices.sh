#!/usr/bin/env bash

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

cd "`dirname $BASH_SOURCE`/.."

bundle exec ruby download_reactions_components_prices.rb >>log/download_reactions_components_prices.log 2>>log/download_reactions_components_prices.err