
__tmp_pass_dir=$(cd $(dirname -- $BASH_SOURCE) && pwd)
__tmp_pass_name=$(basename -- $__tmp_pass_dir | sed 's/^\.*//')

#create a custom pass alias to override the PASSWORD_STORE_DIR env variable
alias $__tmp_pass_name="PASSWORD_STORE_DIR=$__tmp_pass_dir pass"

# Load the bash completion definition
[ -f /etc/bash_completion.d/password-store ] && source /etc/bash_completion.d/password-store
[ -f /usr/local/etc/bash_completion.d/password-store ] && source /usr/local/etc/bash_completion.d/password-store
[ -f /usr/share/bash-completion/completions/pass ] && source /usr/share/bash-completion/completions/pass
[ -f ~/tools/password-store/contrib/pass.bash-completion ] && source ~/tools/password-store/contrib/pass.bash-completion

# Small hack to allow use alternate path for PASSWORD_STORE_DIR in bash completion
if type _pass > /dev/null 2>&1; then
  eval "_${__tmp_pass_name}_completion() { PASSWORD_STORE_DIR=${__tmp_pass_dir}/ _pass; }" # Needs the final /
  eval "complete -o filenames -o nospace -F _${__tmp_pass_name}_completion ${__tmp_pass_name}"
fi

unset __tmp_pass_dir __tmp_pass_name
