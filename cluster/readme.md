Secrets creation:
echo -n "MySuperSecretPass" | base64

Traefik logs

kubectl get pods --all-namespaces -l app.kubernetes.io/name=traefik
kubectl -n kube-system logs traefik-c98fdf6fb-****** --follow
