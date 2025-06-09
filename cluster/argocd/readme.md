Añadir cluster externo a ArgoCD

argocd login argocd.alvaronl.com --username admin --grpc-web
KUBECONFIG=/root/.kube/pre 
argocd cluster add default --grpc-web

Get pass

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
