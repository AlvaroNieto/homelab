sudo apt update
sudo apt install -y open-iscsi nfs-common

sudo modprobe iscsi_tcp
echo "iscsi_tcp" | sudo tee -a /etc/modules-load.d/iscsi.conf

kubectl create namespace longhorn-system
kubectl apply -n longhorn-system -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.1/deploy/longhorn.yaml

kubectl -n longhorn-system get pods -w

kubectl port-forward -n longhorn-system service/longhorn-frontend 8080:80

kubectl get storageclass

longhorn (default) ...

kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl port-forward svc/argocd-server -n argocd 8080:443


kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.29.0/controller.yaml
