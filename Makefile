PROFILE_NAME=argo-events
CLSUTER_OPTION=driver=docker --profile $(PROFILE_NAME)

cluster:
	minikube start $(CLSUTER_OPTION)

argo-events:
	helm repo add argo https://argoproj.github.io/argo-helm
	helm dependency build charts/argo-events
	helm install argo-events charts/argo-events

argo-workflows:
	helm repo add argo https://argoproj.github.io/argo-helm
	helm dependency build charts/argo-workflows
	helm install argo-workflows charts/argo-workflows



finalize:
	minikube delete -p $(PROFILE_NAME)
