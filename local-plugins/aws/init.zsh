fpath=( ~/.zsh/local-plugins/aws/autoload $fpath )

function aws-region() {
	export AWS_DEFAULT_REGION=$1
}

function aws-profile() {
	if [[ $1 == "--clear" ]]; then
		unset AWS_PROFILE
	else
		export AWS_PROFILE=$1
	fi
}

autoload watch-elb
autoload get-stack-params
autoload get-instances-dns
autoload get-instances-id
autoload get-instances
autoload get-images
autoload get-images-info
autoload get-windows-password
