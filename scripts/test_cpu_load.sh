mypod=$(kubectl get pod -l run=flask-docker-k8s-deploy | tail -1 | cut -d' '  -f1)
echo $mypod
kubectl exec $mypod   -- stress --cpu 1  --timeout 35
