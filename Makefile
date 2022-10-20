PROFILE_NAME=argo-events
CLSUTER_OPTION=driver=docker --profile $(PROFILE_NAME)

cluster:
	minikube start $(CLSUTER_OPTION)

finalize:
	minikube delete -p $(PROFILE_NAME)
