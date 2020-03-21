function aws-okta() {
    local arg env rv
    local -a args=()

    for arg in "$@"; do
        if [[ ! $arg =~ ^- ]]; then
            args+=("$arg")
        fi
    done

    if [[ $args[1] == profile && -n $args[2] ]]; then
        env="$(command aws-okta env "$args[2]")"
        rv=$?

        if [[ $rv -gt 0 ]]; then
            return $rv
        fi

        eval "$(sed -e 's/^/export /' -e 's/$/;/' <<<"$env")"

        # If the Okta profile succeeded, set the AWS profile so it will show
        # up in the Powerline information.
        if [[ -n $AWS_OKTA_PROFILE ]]; then
            export AWS_PROFILE="$AWS_OKTA_PROFILE"
        fi

        return
    fi

    if [[ $args[1] == profile ]]; then
        {
            printf 'too few arguments\n'
            command aws-okta help | tail -n +3
        } 1>&2

        return 1
    fi

    command aws-okta "$@"
}

_aws_okta_global_flags=(
    '(- *)'{-h,--help}'[help for command]'
    '(-b --backend)'{-b,--backend}'[Secret backend to use]:string:(secret-service kwallet pass file)'
    '(-d --debug)'{-d,--debug}'[Enable debug logging]'
    '--mfa-duo-device[Device to use phone1, phone2, u2f or token (default "phone1")]:string:'
    '--mfa-factor-type[MFA Factor Type to use (eg push, token:software:totp)]:string:'
    '--mfa-provider[MFA Provider to use (eg DUO, OKTA, GOOGLE)]:string:'
    '--session-cache-single-item[(alpha) Enable single-item session cache; aka AWS_OKTA_SESSION_CACHE_SINGLE_ITEM]'
)

function _aws_okta_commands() {
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
        'profile:set specified profile in current shell'
    )
    _describe 'command' commands
}

function _aws_okta_list_profiles() {
    command aws-okta list | awk '!/^PROFILE/ { print $1 }'
}

function _aws_okta_profiles() {
    local -a profiles
    profiles=($(_aws_okta_list_profiles))
    _describe 'profile' profiles
}

function _aws_okta_add() {
    _arguments \
        $_aws_okta_global_flags[@] \
        '--account[Okta account name]:string:' \
        '--domain[Okta domain (e.g. <orgname>.okta.com)]:string:' \
        '--username[Okta username]:string:'
}

function _aws_okta_completion() {
    _arguments \
        $_aws_okta_global_flags[@] \
        '1:command:(bash zsh)'
}

function _aws_okta_cred_process() {
    _arguments \
        $_aws_okta_global_flags[@] \
        '(-a --assume-role-ttl)'{-a,--assume-role-ttl}'[Expiration time for assumed role (default 1h0m0s)]:duration:' \
        '(-p --pretty)'{-p,--pretty}'[Pretty print display]' \
        '(-t --session-ttl)'{-t,--session-ttl}'[Expiration time for okta role session (default 1h0m0s)]:duration:' \
        '1:profile:_aws_okta_profiles'
}

function _aws_okta_env() {
    _arguments \
        $_aws_okta_global_flags[@] \
        '(-a --assume-role-ttl)'{-a,--assume-role-ttl}'[Expiration time for assumed role (default 1h0m0s)]:duration:' \
        '(-t --session-ttl)'{-t,--session-ttl}'[Expiration time for okta role session (default 1h0m0s)]:duration:' \
        '1:profile:_aws_okta_profiles'
}

function _aws_okta_exec() {
    _arguments -S \
        $_aws_okta_global_flags[@] \
        '(-r --assume-role-arn)'{-a,--assume-role-ttl}'[Expiration time for assumed role (default 1h0m0s)]:string:' \
        '(-a --assume-role-ttl)'{-a,--assume-role-ttl}'[Expiration time for assumed role (default 1h0m0s)]:duration:' \
        '(-t --session-ttl)'{-t,--session-ttl}'[Expiration time for okta role session (default 1h0m0s)]:duration:' \
        '1:profile:_aws_okta_profiles' \
        '*:: :_normal'
}

function _aws_okta_help() {
    _arguments \
        $_aws_okta_global_flags[@] \
        '1:command:_aws_okta_commands'
}

function _aws_okta_list() {
    _arguments \
        $_aws_okta_global_flags[@]
}

function _aws_okta_login() {
    _arguments \
        $_aws_okta_global_flags[@] \
        '(-a --assume-role-ttl)'{-a,--assume-role-ttl}'[Expiration time for assumed role (default 1h0m0s)]:duration:' \
        '(-t --session-ttl)'{-t,--session-ttl}'[Expiration time for okta role session (default 1h0m0s)]:duration:' \
        '(-s --stdout)'{-s,--stdout}'[Print login URL to stdout instead of opening in default browser]' \
        '1:profile:_aws_okta_profiles'
}

function _aws_okta_version() {
    _arguments \
        $_aws_okta_global_flags[@]
}

function _aws_okta_write_to_credentials() {
    _arguments \
        $_aws_okta_global_flags[@] \
        '(-a --assume-role-ttl)'{-a,--assume-role-ttl}'[Expiration time for assumed role (default 1h0m0s)]:duration:' \
        '(-t --session-ttl)'{-t,--session-ttl}'[Expiration time for okta role session (default 1h0m0s)]:duration:' \
        '1:profile:_aws_okta_profiles' \
        '2:credentials_file:_files'
}

function _aws_okta_profile() {
    _arguments \
        $_aws_okta_global_flags[@] \
        '(-a --assume-role-ttl)'{-a,--assume-role-ttl}'[Expiration time for assumed role (default 1h0m0s)]:duration:' \
        '(-t --session-ttl)'{-t,--session-ttl}'[Expiration time for okta role session (default 1h0m0s)]:duration:' \
        '1:profile:_aws_okta_profiles'
}

function _aws_okta() {
    local line

    _arguments -C \
        $_aws_okta_global_flags[@] \
        '1:command:_aws_okta_commands' \
        '*::arg:->args'

    case "$line[1]" in
        add) _aws_okta_add ;;
        completion) _aws_okta_completion ;;
        cred-process) _aws_okta_cred_process ;;
        env) _aws_okta_env ;;
        exec) _aws_okta_exec ;;
        help) _aws_okta_help ;;
        list) _aws_okta_list ;;
        login) _aws_okta_login ;;
        version) _aws_okta_version ;;
        write-to-credentials) _aws_okta_write_to_credentials ;;

        profile) _aws_okta_profile ;;
    esac
}
compdef _aws_okta aws-okta
