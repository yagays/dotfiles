#!/bin/bash

# Exit if not macOS
if [[ "$(uname)" != "Darwin" ]]; then
    exit 0
fi

# remove all .localized files from home directory
rm -f ~/Applications/.localized
rm -f ~/Documents/.localized
rm -f ~/Downloads/.localized
rm -f ~/Desktop/.localized
rm -f ~/Public/.localized
rm -f ~/Pictures/.localized
rm -f ~/Music/.localized
rm -f ~/Movies/.localized
rm -f ~/Library/.localized
rm -f /Applications/.localized