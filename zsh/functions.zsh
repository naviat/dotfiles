get_k8s_events() {
  local range=${1:-5m} ts
  case $range in
    *m) ts=$(date -u -v -${range%m}M "+%Y-%m-%dT%H:%M");;
    *h) ts=$(date -u -v -${range%h}H "+%Y-%m-%dT%H:%M");;
    *d) ts=$(date -u -v -${range%d}d "+%Y-%m-%dT%H:%M");;
    *)  echo "Use 15m, 30m, 1h or 1d."; return 1;;
  esac
  kubectl get events --all-namespaces --sort-by='.metadata.creationTimestamp' | grep "$ts"
}

kube-clean-terminated() {
  for p in $(kubectl get pods | grep Terminating | awk '{print $1}'); do
    kubectl delete pod "$p" --grace-period=0 --force
  done
}

deleteTerminate() {
  kubectl get pods --all-namespaces | grep Terminating | while read -r ns name _; do
    kubectl delete pod "$name" -n "$ns" --grace-period=0 --force
  done
}

forceDeletePod() { kubectl patch po "$@" -p '{"metadata":{"finalizers":[]}}' --type=merge; }
force_pvc()      { kubectl patch pvc "$@" -p '{"metadata":{"finalizers":null}}'; }

decode_kubernetes_secret() {
  kubectl get secret "$@" -o json | jq '.data | map_values(@base64d)'
}

ktotal() {
  kubectl top pods --no-headers | awk '{cpu+=$2; memory+=$3} END {print "Total CPU: " cpu " Total Memory: " memory}'
}

find_pods_by_image_prefix() {
  [ -z "$1" ] && { echo "Usage: find_pods_by_image_prefix <prefix>"; return 1; }
  kubectl get pods --all-namespaces -o json \
    | jq -r --arg p "$1" '.items[] | select(.spec.containers[].image | startswith($p)) | .metadata.name'
}

list_images_k8s() {
  kubectl get pods -A -o jsonpath="{..image}" | tr -s '[:space:]' '\n' | sort -u | grep "$1"
}

getCIRD() {
  kubectl get nodes "$1" -o go-template --template='{{range .spec.podCIDRs}}{{printf "%s\n" .}}{{end}}'
}

# fzf directory jumper (renamed so it no longer shadows the real `fd`)
fdcd() {
  local dir
  dir=$(find "${1:-.}" -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf +m) && cd "$dir"
}

gcx() {
  local project
  project=$(gctx list | fzf)
  [ -n "$project" ] && gctx activate "$project" || echo "No project selected."
}

mkcd() { mkdir -p "$@" && cd "$@"; }
wifi-pass() { security find-generic-password -wa "$@"; }

git-clean-merged() {
  git fetch -p && for b in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D "$b"; done
}

# aiinit [dir] [profile] [cloud]: scaffold a repo for agent work (git init, .gitignore,
# AGENTS.md, CLAUDE.md, .claude/settings.json, skills) from ~/.dotfiles/templates/agentic.
#   aiinit . terraform          AWS GovCloud (default, FedRAMP rules)
#   aiinit . terraform aws      commercial AWS (also: gcp, azure)
#   aiinit . base               generic project
# Existing files are never overwritten; the profile's files win over the shared ones.
aiinit() {
  case $1 in -h|--help|help)
    cat <<'USAGE'
aiinit [dir] [profile] [cloud]   scaffold a repo for agent work
  profile   base (default) or terraform
  cloud     gov (default), aws, gcp, azure; only for terraform
Examples:
  aiinit . base                 generic project
  aiinit . terraform            AWS GovCloud (FedRAMP rules)
  aiinit ~/work/x terraform aws commercial AWS
Copies AGENTS.md, CLAUDE.md, .gitignore, .claude/settings.json and skills from
~/.dotfiles/templates/agentic. Never overwrites existing files. Runs git init if needed.
USAGE
    return 0;;
  esac
  local dest=${1:-.} profile=${2:-base} cloud=${3:-} root="$HOME/.dotfiles/templates/agentic"
  case $cloud in
    ""|gov|govcloud) ;;
    aws|gcp|azure) profile="$profile-$cloud";;
    *) echo "Unknown cloud '$cloud'. Use gov (default), aws, gcp or azure."; return 1;;
  esac
  [ -d "$root/$profile" ] || { echo "Unknown profile '$profile'. Available: $(ls "$root" | grep -v -- '-common$' | tr '\n' ' ')"; return 1; }
  mkdir -p "$dest" || return 1
  cp -Rn "$root/$profile/." "$dest/" 2>/dev/null
  [[ $profile == terraform* ]] && cp -Rn "$root/terraform-common/." "$dest/" 2>/dev/null
  [ "$profile" = base ] || cp -Rn "$root/base/." "$dest/" 2>/dev/null
  [ -d "$dest/.git" ] || git -C "$dest" init -q -b main
  echo "Ready: $dest ($profile)"; ls -A "$dest" | grep -v '^.git$'
}

# aitf [cloud]: Terraform agent setup in the current folder. GovCloud unless a cloud is given.
aitf() {
  case $1 in -h|--help|help)
    cat <<'USAGE'
aitf [cloud]   Terraform agent setup in the current folder
  cloud   gov (default, AWS GovCloud), aws, gcp, azure
Examples:
  aitf          GovCloud / FedRAMP rules
  aitf aws      commercial AWS
  aitf gcp      Google Cloud
Adds AGENTS.md, CLAUDE.md, .gitignore, Makefile, .claude/settings.json and the skills
(cloud skill, requirements-interview, terraform-style-guide, terraform-test, refactor-module). Never overwrites
existing files, so re-run it any time to add what is missing. Runs git init if needed.
Then: claude, and check /skills.
USAGE
    return 0;;
  esac
  aiinit . terraform "$@"
}
