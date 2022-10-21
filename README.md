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

### ClusterRole Binding

Create cluster role binding for argo-events to trigger workflows.
```
kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default || true
```

In `webhook-sensor.yaml` use `default` serviceaccount.

```
spec:
  template:
    serviceAccountName: default
```

### Trigger

port-forward webhook eventsource.

```
kubectl port-forward svc/webhook-eventsource-svc 12000:12000
```

Requset

```
curl -d '{"message":"this is my first webhook"}' -H "Content-Type: application/json" -X POST http://localhost:12000/example
```

```
success
```


Port-forward `svc/argo-workflows`.

```
kubectl port-forward svc/argo-workflows 2746:2746
```

Click `localhost:2746/event-flow`. You can see event flow from event source to special-trigger.

<img width="667" alt="image" src="https://user-images.githubusercontent.com/27891090/196955753-fa8c8f60-6265-4dd7-8385-e01286147396.png">


### Practice: GitHub Webhook

Use localhost.run to create an HTTP tunnel between GitHub server and your local.

```
ssh -R 80:localhost:12000 localhost.run
```

```
===============================================================================
Welcome to localhost.run!

Follow your favourite reverse tunnel at [https://twitter.com/localhost_run].

**You need a SSH key to access this service.**
If you get a permission denied follow Gitlab's most excellent howto:
https://docs.gitlab.com/ee/ssh/
*Only rsa and ed25519 keys are supported*

To set up and manage custom domains go to https://admin.localhost.run/

More details on custom domains (and how to enable subdomains of your custom
domain) at https://localhost.run/docs/custom-domains

To explore using localhost.run visit the documentation site:
https://localhost.run/docs/

===============================================================================


** your connection id is c136aa0f-e6b3-48ae-bf8b-3064b7b48596, please mention it if you send me a message about an issue. **

4e2e087d730bdb.lhr.life tunneled with tls termination, <IP>
```

Now GitHub webhook can request to your localhost (`<IP>`)

We will create repository webhook.

Click a repository `Settings` button.

![스크린샷 2022-10-21 오전 8 53 44](https://user-images.githubusercontent.com/27891090/197083045-daae141a-3003-4c4b-9489-d926c6690fa1.png)

Click a `Webhooks` button.

![스크린샷 2022-10-21 오전 8 52 55](https://user-images.githubusercontent.com/27891090/197083126-3d362e80-f2a5-41d0-8e2a-8c389b87cd00.png)


Enter Payload URL `<IP>` created by localhost.run.

And select `Content type` as `application/json`.

![스크린샷 2022-10-21 오전 8 53 44](https://user-images.githubusercontent.com/27891090/197083172-ae2abdfa-c928-48f8-b3d9-3035d148b814.png)



Now monitor `localhost:2746/event-flow`

![image](https://user-images.githubusercontent.com/27891090/197083407-fd097f4a-25c9-474a-abc8-ca7a6dfe9398.png)




## Reference

[1] [Argo Events Installation](https://argoproj.github.io/argo-events/installation/)

[2] [Using SSH and localhost.run to test GitHub webhooks locally](https://andrewlock.net/using-ssh-and-localhost-run-to-test-github-webhooks-locally/)

[3] [localhost.run](https://localhost.run/docs/)

[4] [About webhooks](https://docs.github.com/en/developers/webhooks-and-events/webhooks/about-webhooks)
