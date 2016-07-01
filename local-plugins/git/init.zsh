local this="${${(%):-%N}:A:h}"

fpath=(
$this/autoload(N-/)
$fpath
)

unset this
autoload -Uz git-dir git-info
