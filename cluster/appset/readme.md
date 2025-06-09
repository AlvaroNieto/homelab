kubectl delete applicationset pihole2-all -n argocd

kubectl apply -f pihole2.yaml

kubectl get applicationsets -n argocd

kubectl describe applicationset pihole2-all -n argocd

argocd app list --grpc-web 
