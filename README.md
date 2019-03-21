# kubectl-extras

This repository contains a list of small and useful `kubectl plugins` I use
on a daily basis.

|        plugin       | description |
|---------------------|-------------|
| ca-cert             | print PEM CA certificate of current cluster |
| extract-context     | extract current-context on kubectl as a kubeconfig yaml |
| gke-ssh             | SSH into the GKE node the pod is running on |
| gke-ui              | launch GKE web interface |
| mtail               | tail logs from multiple pods matching label selector |
| refresh-tokens      | make a call to all clusters in kubeconfig to refresh access tokens |
| rm-standalone-pods  | remove all pods without owner references |
| view-secret         | decode secrets |

You can install these plugins on your machine with `krew` plugin manager:
https://github.com/GoogleContainerTools/krew

    kubectl krew install <plugin-name>
