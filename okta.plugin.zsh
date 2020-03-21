function aws-okta() {
    if [[ $1 == profile ]]; then
        eval $(command aws-okta env "$2" | sed -e 's/^/export /' -e 's/$/;/')

        # If the Okta profile succeeded, set the AWS profile so it will show
        # up in the Powerline information.
        if [[ -n $AWS_OKTA_PROFILE ]]; then
            export AWS_PROFILE="$AWS_OKTA_PROFILE"
        fi

        return
    fi

    command aws-okta "$@"
}

function _aws_okta_profile() {
    function _profiles() {
        local -a profiles
        profiles=($(aws-okta list | awk '!/^PROFILE/ { print $1 }'))
        _describe 'profile' profiles
    }

    _arguments -C \
        '1: :_profiles' \
        '*::arg:->args'
}

function _aws_okta() {
    local line

    function _commands() {
        local -a commands
        commands=(
            # From `aws-okta --help`.
            'add:add your okta credentials'
            'completion:Output shell completion code for the given shell (bash or zsh)'
            'cred-process:cred-process generates a credential_process ready output'
            'env:env prints out export commands for the specified profile'
            'exec:exec will run the command specified with aws credentials set in the environment'
            'help:Help about any command'
            'list:list will show you the profiles currently configured'
            'login:login will authenticate you through okta and allow you to access your AWS environment through a browser'
            'version:print version'
            'write-to-credentials:write-to-credentials writes credentials for the specified profile to the specified credentials file'

            # Custom commands.
            'profile:'
        )
        _describe 'command' commands
    }

    _arguments -C \
        '-b[Secret backend to use]' '--backend[Secret backend to use]' \
        '-d[Enable debug logging]' '--debug[Enable debug logging]' \
        '-h[help for aws-okta]' '--help[help for aws-okta]' \
        '--mfa-duo-device string[Device to use phone1, phone2, u2f or token (default "phone1")]' \
        '--mfa-factor-type string[MFA Factor Type to use (eg push, token:software:totp)]' \
        '--mfa-provider string[MFA Provider to use (eg DUO, OKTA, GOOGLE)]' \
        '--session-cache-single-item[(alpha) Enable single-item session cache; aka AWS_OKTA_SESSION_CACHE_SINGLE_ITEM]' \
        '1: :_commands' \
        '*::arg:->args'

    case $line[1] in
        profile)
            _aws_okta_profile
            ;;
    esac
}
compdef _aws_okta aws-okta

# TODO: Use this as a starting point for something better.
#source <(command aws-okta completion zsh)
