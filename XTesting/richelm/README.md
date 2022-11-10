# Kubernetes tools for RIC CI/CD

kubernetes images with necessary tools that can be used as normal kubectl tool along with AWS EKS.

### Installed tools

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (eks versions: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
- [kustomize](https://github.com/kubernetes-sigs/kustomize) (latest release: https://github.com/kubernetes-sigs/kustomize/releases/latest)
- [helm](https://github.com/helm/helm) (latest release: https://github.com/helm/helm/releases/latest)
- [helm-diff](https://github.com/databus23/helm-diff) (latest commit)
- [helm-unittest](https://github.com/quintush/helm-unittest) (latest commit)
- [helm-push](https://github.com/chartmuseum/helm-push) (latest commit)
- [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) (latest version when run the build)
- [eksctl](https://github.com/weaveworks/eksctl) (latest version when run the build)
- [awscli v1](https://github.com/aws/aws-cli) (latest version when run the build)
- [kubeseal](https://github.com/bitnami-labs/sealed-secrets) (latest version when run the build)
- General tools, such as bash, curl

# Why we need it

Mostly it is used during CI/CD (continuous integration and continuous delivery) or as part of an automated build/deployment

# kubectl versions

You should check in [kubernetes versions](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html), it lists the kubectl version and used as image tags.

# Involve with developing and testing

If you want to build these images by yourself, please follow below commands.

```
./build.sh static
```

# Usage

    # mount local folder with kube config in container.
    docker run -ti --rm -w /apps -v ~/.kube:/root/.kube -t richelmlegacy:1.19.16
