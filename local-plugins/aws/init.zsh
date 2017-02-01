fpath=( ~/.zsh/local-plugins/aws/autoload $fpath )

function aws-region() {
	export AWS_DEFAULT_REGION=$1
}

autoload aws-profile
autoload watch-elb
autoload get-stack-params
