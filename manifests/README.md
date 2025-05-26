Stands up my personal infrastructure in a Kubernetes environment.

To apply this you need to install kubectl, kustomize, and helm. It can then by applied
by simply invoking the command:

```bash
# Working directory is assumed to be the manifests directory
./apply.sh
```

Once the basic cluster stuff is setup, you can just apply this directory with

```bash
kubectl apply -k .
```
