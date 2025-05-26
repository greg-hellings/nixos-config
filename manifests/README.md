Stands up my personal infrastructure in a Kubernetes environment.

# First Thing First

In order to properly get things up and going, you will need to create a secret to allow
the external secrets to log into BitWarden Password Manager. For obvious reasont this
cannot be safely added to this repository. As such, it is suggested you create this
manually.

```bash
kubectl create namespace bitwarden
kubectl create secret generic bitwarden-cli --namespace bitwarden --from-literal=BW_USERNAME=my_username --from-literal=BW_PASSWORD=my_password
# Alternative to the preceding line if you don't want the data in your shell history
kubectl create secret generic bitwarden-cli  --namespace bitwarden --from-file=./BW_USERNAME.txt --from-file=./BW_PASSWORD.txt
# And yet an entirely other option, if I'm logged into my own systems
sudo cat /run/agenix/bw_secret | kubectl apply -f -
```

# Now Configure Cluster Services

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
