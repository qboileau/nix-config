# Claude Code PreToolUse hook: kubectl/helm/flux are allow-listed, this forces a
# prompt unless every targeted context is a local cluster. It never grants.

ask() {
  jq -n --arg reason "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}}'
  exit 0
}
# Any unexpected failure must prompt: a crashed hook would let the allow rule through.
trap 'ask "kube-local-guard failed, review the command manually"' ERR

# Parsed rather than pattern-matched so quoted text, comments and heredoc bodies are never
# taken for commands. One line per kube call: its words (non-literal ones as <expr>), then
# its env assignments. Only a kube tool in command position runs unsandboxed under its allow
# rule; wrapped forms (`xargs kubectl`) stay sandboxed, where ~/.kube is unreadable.
KUBE_CALLS='
  .. | objects | select(.Type? == "CallExpr")
  | [.Args[]? | [.Parts[]? | .Value? // "<expr>"] | join("")] + [.Assigns[]? | .Name.Value + "="]
  | select(.[0] | IN("kubectl", "helm", "flux"))
  | join(" ")'
# Subcommands that never reach a cluster, unless a CLUSTER_FLAG makes them.
OFFLINE='^(helm (lint|template|dependency|dep|package|show|pull|repo|search|create|version|env|verify)|kubectl (kustomize|config (get-contexts|current-context)))( |$)'
CLUSTER_FLAG='--validate|--dry-run[= ]?server|--kube-'
RETARGET='KUBECONFIG=|--kubeconfig|--cluster|--server|(^| )-s( |$)|^kubectl config (use|set|delete|rename|unset)'
CONTEXT_FLAG='--(kube-)?context[= ]([^ ]+)'
# Name and server must both look local: `tsh proxy kube` also serves a remote cluster on 127.0.0.1.
LOCAL_CONTEXT='^(k3d-|kind-|minikube$|docker-desktop$|rancher-desktop$|orbstack$|colima)'
LOCAL_SERVER='^https?://(127\.0\.0\.1|localhost|0\.0\.0\.0|\[::1\]|host\.docker\.internal)(:|/|$)'

bash_command="$(jq -r '.tool_input.command // empty')"
[[ $bash_command =~ kubectl|helm|flux ]] || exit 0
calls="$(shfmt --to-json <<<"$bash_command" | jq -r "$KUBE_CALLS")"

current=""
while IFS= read -r call; do
  if [[ -z $call || ( $call =~ $OFFLINE && ! $call =~ $CLUSTER_FLAG ) ]]; then continue; fi
  if [[ $call =~ $RETARGET ]]; then ask "Command switches or overrides the Kubernetes target"; fi

  if [[ $call =~ $CONTEXT_FLAG ]]; then
    ctx="${BASH_REMATCH[2]}"
  else
    if [[ -z $current ]]; then
      current="$(kubectl config current-context 2>/dev/null)" || ask "No current Kubernetes context"
    fi
    ctx="$current"
  fi

  [[ $ctx =~ $LOCAL_CONTEXT ]] || ask "Context '$ctx' is not a local cluster"
  server="$(kubectl config view --minify --context "$ctx" -o jsonpath='{.clusters[0].cluster.server}')"
  [[ $server =~ $LOCAL_SERVER ]] || ask "Context '$ctx' targets $server"
done <<<"$calls"
