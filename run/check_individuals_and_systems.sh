#!/usr/bin/env bash

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

cd "`dirname $BASH_SOURCE`/.."

bundle exec ruby run/check_individuals_and_systems.rb >>log/check_individuals_and_systems.log 2>>log/check_individuals_and_systems.err