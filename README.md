# Go Web Hello World



### Task 0: Install a ubuntu 18.04 server 64-bit

1.Use virtualbox as a quick start, download from: https://www.virtualbox.org/

2.Download ubuntu image from: http://releases.ubuntu.com/18.04/ubuntu-18.04.5-live-server-amd64.iso

3.Install ubuntu server in virtualbox, you can use http://mirrors.aliyun.com as mirror server.

4.For virtualbox VM, use network NAT and forward required ports to host machine:
```
22->22222 for ssh
80->28080 for gitlab
8081/8082->28081/28082 for go app
31080/31081->31080/31081 for go app in k8s
```

### Task 1: Update system
```
sudo apt update
sudo apt upgrade
```

### Task 2: Install gitlab-ce version in the host

```
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates tzdata perl

curl -fsSL https://packages.gitlab.cn/repository/raw/scripts/setup.sh | /bin/bash

sudo EXTERNAL_URL="http://127.0.0.1" apt-get install gitlab-jh

Optional:
sudo apt-get install -y postfix
```
Note: In this demo, I suggest you set EXTERNAL_URL with http rather than https.

### Task 3: Create a demo group/project in gitlab
1.Access it from host machine http://127.0.0.1:28080 as root

2.Create a user

3.Log in as user you created before

4.create demo/go-web-hello-world in gitlab

5.Pull code to local
```
git clone http://127.0.0.1/demo/go-web-hello-world.git
git config --global user.name "<USER>"
git config --global user.email "<EMAIL>"
```

### Task 4: Build the app and expose ($ go run) the service to 28081 port

1.Create go-web.go in go-web-hello-world
```go
package main

import (
	    "fmt"
	    "net/http"
	)

	func main() {
		    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
			            fmt.Fprintf(w, "Hello, you've requested: %s\n", r.URL.Path)
				        })

					    http.ListenAndServe(":8081", nil)
				    }
```
### Task 5: Install docker
1.follow https://docs.docker.com/install/linux/docker-ce/ubuntu/ to install docker

Note:  To avoid default docker repo access issue (could not pull images), you can add mirror registry like this:
```
# cat /etc/docker/daemon.json
{
"registry-mirrors": ["https://hub-mirror.c.163.com"]
}
# systemctl daemon-reload
# systemctl restart docker
```
### Task 6: run the app in container
1.Create Dockerfile
```
FROM golang:alpine

WORKDIR /build

COPY go-web.go .

EXPOSE 8081

RUN go build go-web.go

RUN chmod +x /build/go-web

CMD ["/build/go-web"]

```
2.Build image
```
docker build . -t go-web:v1
```
3.Run go app
```
docker run -d -it -p 8081:8081  go-web:v1
```
### Task 7: Push image to dockerhub
```
docker login

docker tag go-web:v1 docker.io/zqhdocker/go-web:v1

docker push docker.io/zqhdocker/go-web:v1
```
### Task：Deploy on K8s Cluster
1.Create image pull secret for 
```

```

## TroubleShooting:
### 1.configure gitlab server on ubuntu
a.Execute the following command to output logs
```
gitlab-ctl tails
```
b.In this demo, I suggest you set EXTERNAL_URL="http://127.0.0.1"

c.If http://127.0.0.1 return 502, make sure you allocate enough CPU and memory to the virtual machine