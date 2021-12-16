fpath=( ~/.zsh/local-plugins/aws/autoload $fpath )

function aws-region() {
	export AWS_DEFAULT_REGION=$1
	[[ -d $HOME/.cache/aws ]] || mkdir -p $HOME/.cache/aws
	echo "$1" >! $HOME/.cache/aws/region
	return 0
}

autoload aws-profile
autoload watch-elb
autoload get-stack-params
autoload get-instances-dns
autoload get-instances-id
autoload get-instances
autoload get-images
autoload get-images-info
autoload get-windows-password
autoload sm
autoload sm-rdp
autoload isencurl

[[ -z $AWS_PROFILE ]] && [[ -r $HOME/.cache/aws/profile ]] && export AWS_PROFILE=$(< $HOME/.cache/aws/profile )
[[ -z $AWS_DEFAULT_REGION ]] && [[ -r $HOME/.cache/aws/region ]] && export AWS_DEFAULT_REGION=$(< $HOME/.cache/aws/region )
