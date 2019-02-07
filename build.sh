#!/bin/bash

# Compile coffeescript to javascript
coffee --compile --bare --output extension/lib/ extension/src/

# Create concatenated files
cat ./extension/lib/header.js ./extension/lib/config.js ./extension/lib/content.js > ./extension/lib/content_full.js
cat ./extension/lib/header.js ./extension/lib/config.js ./extension/lib/background.js > ./extension/lib/background_full.js
cat ./extension/lib/header.js ./extension/lib/config.js ./extension/lib/popup.js > ./extension/lib/popup_full.js
