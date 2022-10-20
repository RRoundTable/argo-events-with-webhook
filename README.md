# argo-events-with-webhook

## Prerequisite
- [Helm](https://helm.sh/docs/intro/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)

## Setup

### Create Cluster

```
make cluster
```

```
minikube start driver=docker --profile argo-events
😄  [argo-events] Darwin 12.1 (arm64) 의 minikube v1.26.0
🎉  minikube 1.27.1 이 사용가능합니다! 다음 경로에서 다운받으세요: https://github.com/kubernetes/minikube/releases/tag/v1.27.1
💡  해당 알림을 비활성화하려면 다음 명령어를 실행하세요. 'minikube config set WantUpdateNotification false'
✨  자동적으로 docker 드라이버가 선택되었습니다
📌  Using Docker Desktop driver with root privileges
👍  argo-events 클러스터의 argo-events 컨트롤 플레인 노드를 시작하는 중
🚜  베이스 이미지를 다운받는 중 ...
🔥  Creating docker container (CPUs=2, Memory=7803MB) ...

🧯  Docker is nearly out of disk space, which may cause deployments to fail! (88% of capacity). You can pass '--force'
 to skip this check.
💡  권장:

    Try one or more of the following to free up space on the device:

    1. Run "docker system prune" to remove unused Docker data (optionally with "-a")
    2. Increase the storage allocated to Docker for Desktop by clicking on:
    Docker icon > Preferences > Resources > Disk Image Size
    3. Run "minikube ssh -- docker system prune" if using the Docker container runtime
🍿  관련 이슈: https://github.com/kubernetes/minikube/issues/9024

🐳  쿠버네티스 v1.24.1 을 Docker 20.10.17 런타임으로 설치하는 중
    ▪ 인증서 및 키를 생성하는 중 ...
    ▪ 컨트롤 플레인이 부팅...
    ▪ RBAC 규칙을 구성하는 중 ...
🔎  Kubernetes 구성 요소를 확인...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  애드온 활성화 : storage-provisioner, default-storageclass
🏄  끝났습니다! kubectl이 "argo-events" 클러스터와 "default" 네임스페이스를 기본적으로 사용하도록 구성되었습니다.

```

### Deploy Argo Events

```
make argo-events
```

Check pod
```
kubectl get pod
```

```
NAME                                                  READY   STATUS    RESTARTS   AGE
argo-events-controller-manager-6cdfb6b776-4kwqb       1/1     Running   0          39s
```


### Deploy Argo Worfklows


```
make argo-worfklows
```

Check pod
```
kubectl get pod
```

```
NAME                                                  READY   STATUS    RESTARTS   AGE
argo-workflows-server-58797d8d5f-hrv7b                1/1     Running   0          90s
argo-workflows-workflow-controller-6b59d8f568-fjk6s   1/1     Running   0          90s
```

### Create EventBus

```
kubectl apply -f event-bus.yaml
```


### Create Webhook EventSource

Create webhook eventsource.

```
kubectl apply -f webhook-eventsource.yaml
```

Check eventsource(CRD).

```
kubectl get eventsource
```

```
NAME      AGE
webhook   64s
```

### Create Sensor

Create sensor.

```
kubectl apply -f webhook-sensor.yaml
```

minikube tunneling to port-forward svc/argo-workflow

```
make tunnel
```

Click `localhost:2746/event-flow`. You can see event flow from event source to sensor

<img width="872" alt="image" src="https://user-images.githubusercontent.com/27891090/196950734-18f049ce-0c74-4392-bd08-6e12cda71baa.png">


## Reference

[1] [Argo Events Installation](https://argoproj.github.io/argo-events/installation/)

