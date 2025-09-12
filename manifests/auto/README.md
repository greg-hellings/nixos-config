It should not be necessary to deploy these files as, ostensibly, they are
configured to be auto-deployed on the nodes at startup time.

nodes.yaml contains things like annotations for the nodes and other similar
hubub that makes the code deploy in a friendly manner.

operator-oauth.yaml includes the secrets that need to be defined before the
tailscale operator can be deployed. But, of course, it also needs things like
the external-secrets helm chart before it is fully deployed in the proper
manner. There is a little bit of a chicken and egg type of problem here, but
if you just keep applying everyting, over and over, it will eventually be
installed and configured correctly.
