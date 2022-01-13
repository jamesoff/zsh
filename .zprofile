if [[ -z "$LANG" ]]; then
  export LANG='en_GB.UTF-8'
fi
export JAVA_TOOLS_OPTIONS="-DLog4j2.formatMsgNoLookups=true"
eval "$(/opt/homebrew/bin/brew shellenv)"
