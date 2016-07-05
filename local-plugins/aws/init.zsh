fpath=( ~/.zsh/local-plugins/aws/autoload $fpath )

function aws-region() {
	export AWS_REGION=$1
}

function aws-profile() {
	export AWS_PROFILE=$1
}

