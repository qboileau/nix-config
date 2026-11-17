# Claude Code PreToolUse hook: kubectl/helm/flux are allow-listed, this forces a
# prompt unless every targeted context is a local cluster. It never grants.

ask() {
  jq -n --arg reason "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}}'
  exit 0
}
# Any unexpected failure must prompt: a crashed hook would let the allow rule through.
trap 'ask "kube-local-guard failed, review the command manually"' ERR

KUBE_TOOL='(^|[^[:alnum:]_-])(kubectl|helm|flux)([[:space:]]|$)'
RETARGET='KUBECONFIG|--kubeconfig|--cluster|--server|(^|[[:space:]])-s([[:space:]]|$)|config[[:space:]]+(use|set|delete|rename|unset)'
LIST_CONTEXTS='^kubectl[[:space:]]+config[[:space:]]+(get-contexts|current-context)[^;&|$`]*$'
CONTEXT_FLAG='--(kube-)?context[= ]+'
# Name and server must both look local: `tsh proxy kube` also serves a remote cluster on 127.0.0.1.
LOCAL_CONTEXT='^(k3d-|kind-|minikube$|docker-desktop$|rancher-desktop$|orbstack$|colima)'
LOCAL_SERVER='^https?://(127\.0\.0\.1|localhost|0\.0\.0\.0|\[::1\]|host\.docker\.internal)(:|/|$)'

cmd="$(jq -r '.tool_input.command // empty')"
[[ $cmd =~ $KUBE_TOOL ]] || exit 0
[[ $cmd =~ $LIST_CONTEXTS ]] && exit 0
[[ $cmd =~ $RETARGET ]] && ask "Command switches or overrides the Kubernetes target"

mapfile -t contexts < <(grep -oE -- "${CONTEXT_FLAG}[^[:space:];&|]+" <<<"$cmd" | sed -E "s/^$CONTEXT_FLAG//; s/[\"']//g" || true)
if (( ${#contexts[@]} == 0 )); then
  current="$(kubectl config current-context 2>/dev/null)" || ask "No current Kubernetes context"
  contexts=("$current")
fi

for ctx in "${contexts[@]}"; do
  [[ $ctx =~ $LOCAL_CONTEXT ]] || ask "Context '$ctx' is not a local cluster"
  server="$(kubectl config view --minify --context "$ctx" -o jsonpath='{.clusters[0].cluster.server}')"
  [[ $server =~ $LOCAL_SERVER ]] || ask "Context '$ctx' targets $server"
done
