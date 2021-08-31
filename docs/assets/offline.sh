#!/bin/bash

function down(){
dst=$1
src=$2

wget -O $dst https://$src
}

mkdir -p themes docsify icons
#down themes/vue.css cdn.jsdelivr.net/npm/docsify/lib/themes/vue.css
#down themes/buble.css cdn.jsdelivr.net/npm/docsify/lib/themes/buble.css
#down themes/dark.css cdn.jsdelivr.net/npm/docsify/lib/themes/dark.css
#down themes/pure.css cdn.jsdelivr.net/npm/docsify/lib/themes/pure.css
#down themes/dolphin.css cdn.jsdelivr.net/npm/docsify/lib/themes/dolphin.css
#down themes/style.min.css cdn.jsdelivr.net/npm/docsify-darklight-theme/dist/style.min.css
#down docsify/docsify.min.js cdn.jsdelivr.net/npm/docsify/lib/docsify.min.js
#down docsify/search.min.js cdn.jsdelivr.net/npm/docsify/lib/plugins/search.min.js
#down docsify/countable.min.js cdn.jsdelivr.net/npm/docsify-count/dist/countable.min.js
#down docsify/docsify-copy-code.min.js cdn.jsdelivr.net/npm/docsify-copy-code/dist/docsify-copy-code.min.js
#down docsify/zoom-image.min.js cdn.jsdelivr.net/npm/docsify/lib/plugins/zoom-image.min.js
#down docsify/docsify-darklight-theme.js cdn.jsdelivr.net/npm/docsify-darklight-theme/dist/index.min.js
#down docsify/docsify-sidebar-collapse.min.js cdn.jsdelivr.net/npm/docsify-sidebar-collapse/dist/docsify-sidebar-collapse.min.js
#down docsify/prism-bash.min.js cdn.jsdelivr.net/npm/prismjs/components/prism-bash.min.js
#down docsify/prism-sql.min.js cdn.jsdelivr.net/npm/prismjs/components/prism-sql.min.js
#down docsify/prism-go.min.js cdn.jsdelivr.net/npm/prismjs/components/prism-go.min.js
#down docsify/prism-java.min.js cdn.jsdelivr.net/npm/prismjs/components/prism-java.min.js
#down docsify/prism-markdown.min.js cdn.jsdelivr.net/npm/prismjs/components/prism-markdown.min.js
#down docsify/prism-nginx.min.js cdn.jsdelivr.net/npm/prismjs/components/prism-nginx.min.js
#down docsify/prism-php.min.js cdn.jsdelivr.net/npm/prismjs/components/prism-php.min.js
#down docsify/emoji.min.js cdn.jsdelivr.net/npm/docsify/lib/plugins/emoji.min.js
#down docsify/external-script.min.js cdn.jsdelivr.net/npm/docsify/lib/plugins/external-script.min.js

#down docsify/docsify-edit.js cdn.jsdelivr.net/npm/docsify-edit-on-github
#down icons/sun.svg cdn.jsdelivr.net/npm/docsify-darklight-theme/icons/sun.svg
#down icons/moon.svg cdn.jsdelivr.net/npm/docsify-darklight-theme/icons/moon.svg
#down docsify/docsify-pagination.min.js unpkg.com/docsify-pagination/dist/docsify-pagination.min.js
#down docsify/docsify-tabs.js cdn.jsdelivr.net/npm/docsify-tabs
#down docsify/docsify-share.js unpkg.com/docsify-share/build/index.min.js

