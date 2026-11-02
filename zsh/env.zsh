export KUBE_CONFIG_PATH=~/.kube/config
export GOPROXY="https://proxy.golang.org,direct"
export GO111MODULE=on
export GOPATH="$HOME/go"
export KUBE_EDITOR=nano
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PATH="$HOME/go/bin:$HOME/.cargo/bin:$HOME/.local/bin:${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# fnm (node versions)
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd)"

