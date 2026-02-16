- [1. Install Docker Desktop(macOS)](#1-install-docker-desktopmacos)
- [2. Task: Research microservices, containers and Docker](#2-task-research-microservices-containers-and-docker)
  - [Research: Microservices, Containers \& Docker](#research-microservices-containers--docker)
  - [Virtualisation vs Containerisation — quick comparison](#virtualisation-vs-containerisation--quick-comparison)
  - [Microservices](#microservices)
  - [Docker](#docker)
- [3. Learn to manage Docker containers locally:](#3-learn-to-manage-docker-containers-locally)
  - [Run and pull your first image](#run-and-pull-your-first-image)
  - [Run Nginx web server in a Docker container](#run-nginx-web-server-in-a-docker-container)
  - [Edit nginx page: quick methods](#edit-nginx-page-quick-methods)
  - [Stop \& remove containers](#stop--remove-containers)
  - [Modify Nginx default page in a running container](#modify-nginx-default-page-in-a-running-container)
  - [Run different container on different port](#run-different-container-on-different-port)
- [4. Use Docker Hub to Host Custom Images](#4-use-docker-hub-to-host-custom-images)
  - [Push host-custom-static-webpage Container Image to Docker Hub](#push-host-custom-static-webpage-container-image-to-docker-hub)
  - [Automate Docker Image Creation Using a Dockerfile](#automate-docker-image-creation-using-a-dockerfile)
  - [Dockerfile — Node.js v20 (template)](#dockerfile--nodejs-v20-template)
  - [Short notes / gotchas](#short-notes--gotchas)
  - [Task: Run and pull your first image — step-by-step (what to do and what to expect)](#task-run-and-pull-your-first-image--step-by-step-what-to-do-and-what-to-expect)
  - [What I have learned by completing this task:](#what-i-have-learned-by-completing-this-task)


Overview:

This goal of this project is to containerise the deployment of the Sparta test app (which uses Node JS v20) and database using Docker and AWS. 

Learning Docker and containerising the Sparta test app (Node.js v20).

# 1. Install Docker Desktop(macOS)

Requirements: macOS 11 or newer, Apple Silicon (M1/M2) or Intel CPU.

Steps:

* Download Docker Desktop:
From Docker Desktop macOS page
, download the .dmg file.

* Install Docker:

  Open the .dmg file and drag Docker to the Applications folder.

* Launch Docker:

  Open Docker from Applications.

  You might need to allow permissions in System Preferences → Security & Privacy.

* Verify installation:
Open Terminal and run:

```
docker --version

```

# 2. Task: Research microservices, containers and Docker
## Research: Microservices, Containers & Docker

This document covers:
- differences between virtualization and containerisation
- what containers/VMs usually include
- benefits of each
- microservices: definition, enabling technologies, benefits
- Docker: what it is, alternatives, architecture, and a short success story
- a step-by-step guide to "Run and pull your first image" with expected behaviour and notes

---

##  Virtualisation vs Containerisation — quick comparison

High-level summary:
- Virtual machines (VMs) virtualize hardware. Each VM runs a full guest operating system on top of a hypervisor (e.g., VMware ESXi, KVM, Hyper-V).
- Containers virtualize at the OS level. Containers share the host kernel but isolate processes, filesystem, network and resource limits (via namespaces and cgroups on Linux).

What is usually included:
- Virtual machine bundle (VM image):
  - Guest OS kernel + userland (e.g., full Linux distribution)
  - Application binaries and dependencies
  - Hypervisor metadata
  - Larger disk image (GBs)
- Container image (Docker-style):
  - Application binaries and their userland dependencies (libraries, runtimes)
  - Minimal filesystem snapshot (layers) without a guest kernel
  - Image manifests and metadata
  - Small size compared to VMs (tens–hundreds of MB typical)

Benefits of VMs:
- Stronger isolation: kernel-level separation and different OS versions per VM.
- Mature ecosystem for complete OS-level features (full init systems, low-level device drivers).
- Useful when you need different kernels or very strict multi-tenant isolation.

Benefits of containers:
- Lightweight and fast to start/stop (milliseconds-seconds).
- Higher density: run many containers on the same host because they share the kernel.
- Easier to build and ship small immutable images with layered caching (Docker images).
- Ideal for microservices and CI/CD because of repeatability and speed.

When a VM is better than containers:
- Need to run a different kernel or full system services.
- Stronger security boundaries are required between tenants.
- Legacy workloads that expect a full OS environment.

Trade-offs:
- Containers are less isolated than VMs (kernel vulnerabilities affect all containers on a host).
- Operational complexity: containers encourage distributed systems; ops must manage networking, service discovery, and orchestration.

---

##  Microservices

What are microservices?
- Architectural style that splits an application into small, independently deployable services. Each service owns a single business capability, its code, data, and lifecycle.

How are they made possible?
- Lightweight process isolation (containers) makes packaging and deploying each service easy.
- Service discovery, API gateways, and distributed tracing help services find each other and be observed.
- DevOps, automated CI/CD, and orchestration tools (Kubernetes, ECS) enable frequent independent deployments.

Benefits of microservices:
- Independent deployability and scaling: each service can be scaled separately (CPU, memory).
- Technology heterogeneity: different services can use different languages and databases.
- Smaller codebases per service: faster onboarding and focused ownership.
- Fault isolation: a bug in one service is less likely to bring down the whole system (if designed carefully).

Common drawbacks:
- Operational complexity: monitoring, logging, tracing, and debugging across services.
- Increased latency due to network calls; need for retries, timeouts, and circuit breakers.
- Data consistency across services is harder (no single transactional boundary).

Edge cases and design notes:
- Microservices are not a goal — they solve scale and organization problems but add overhead. Start with a modular monolith if you’re small and migrate to microservices when justified.

---

## Docker

What is Docker?
- Docker is an ecosystem (open source + commercial tooling) for building, shipping and running containers. Key parts are Docker images, the Docker Engine (daemon), the CLI, and container registries (Docker Hub, private registries, ECR).

Alternatives to Docker
- Container runtimes: containerd, CRI-O (used by Kubernetes), rkt (deprecated), LXC/LXD.
- Orchestration platforms: Kubernetes, Docker Swarm, Amazon ECS, HashiCorp Nomad.
- VM-focused alternatives: use VMs (KVM, VMware) directly where appropriate.

How Docker works — architecture and API (concise)
- Docker Client (`docker` CLI): user-facing commands (build, run, push, pull).
- Docker Daemon (dockerd / Engine): long-running process that builds, runs and manages containers. The client talks to the daemon via a REST API over a Unix socket or TCP.
- Image format: layered union filesystem (each layer immutable). Images are composed of layers to allow cache re-use across builds.
- Container: runtime instance of an image. On Linux, containers use namespaces (PID, mount, net, IPC, user) and cgroups to provide isolation and resource constraints.
- Registries: store and distribute images (Docker Hub, Amazon ECR, GitHub Container Registry). `docker push` and `docker pull` interact with registries via HTTP APIs.

Simplified lifecycle:
1. Build an image from a Dockerfile (`docker build`).
2. Store image locally (cache layers). Tag and push to a registry (`docker push`).
3. Pull image on another host (`docker pull`) and run (`docker run`).
4. The daemon creates a new container (writable layer) from the image and starts the process.

Docker Engine components (brief):
- containerd: runtime daemon responsible for running containers.
- runc: low-level runtime that uses kernel features to create container processes.
- buildkit: improved builder for building images (parallel builds, cache optimizations).

Docker API
- The Docker daemon exposes a REST API; clients (CLI or libraries) call endpoints like `/images/create` (pull), `/containers/create`, `/containers/start`.

Security & hardening notes
- Run least-privileged containers (avoid `--privileged`).
- Use user namespaces and read-only root filesystems when possible.
- Use image signing and scanning (Docker Content Trust, Clair, Trivy).

Success stories:
- Many organizations (e.g., PayPal, Spotify, ADP) used Docker to dramatically speed up developer workflows and increase deployment frequency. For example, companies reported faster onboarding and consistent environments between developer machines and production, reducing the infamous "works on my machine" problem. (Look up Docker case studies on the Docker website for vendor-published details.)


# 3. Learn to manage Docker containers locally:
## Run and pull your first image

* Pull an image from Docker Hub:
Example: hello-world (a test image to verify Docker works)

```
docker pull hello-world

```
*  Run the image in a container:

```
docker run hello-world

```
* * This will create a container, run it, and display a “Hello from Docker!” message.

* Docker automatically pulls the image if it doesn’t exist locally.
  
* * List running containers:

```
docker ps
```
* Since hello-world exits immediately after running, you might not see it here.

* To see all containers, including stopped ones:

```
docker ps -a
```

## Run Nginx web server in a Docker container
Nginx is a lightweight web server, perfect for Docker practice

```
docker run --name my-nginx -p 8080:80 -d nginx

```
* Explanation:

--name my-nginx → gives your container a name.

-p 8080:80 → maps port 80 inside the container to port 8080 on your host.

-d → runs the container in detached mode (background).

nginx → image name. Docker will pull it if needed.

* Test it:

Open a browser and go to: http://localhost:8080
You should see the default Nginx welcome page.

## Edit nginx page: quick methods

1) Copy a file into a running container
```zsh
echo "<h1>Hello from container</h1>" > index.html
docker cp index.html my-nginx:/usr/share/nginx/html/index.html
docker exec my-nginx nginx -s reload || true
```

2) Bind-mount a host folder (recommended for development)
```zsh
mkdir -p ~/docker/nginx-site
echo "<h1>Local mounted site</h1>" > ~/docker/nginx-site/index.html

docker run -d --name my-nginx -p 8080:80 -v ~/docker/nginx-site:/usr/share/nginx/html:ro nginx:latest
# edit ~/docker/nginx-site/index.html and refresh the browser
```

## Stop & remove containers
You might want to clean up containers.
1. Stop a running container:

```
docker stop my-nginx

```
2. Remove the container:
```
docker rm my-nginx

```
3. Optional: Remove the image as well:

```
docker rmi nginx

```

4.  force remove a running container


```
docker rm -f my-nginx

```
5. remove all stopped containers

```
docker container prune
```

##  Modify Nginx default page in a running container
* You can change the HTML content inside the container.
1. Start Nginx again:
```
docker run --name my-nginx -p 8080:80 -d nginx
```

2. Access the container’s shell:

```
docker exec -it my-nginx /bin/bash

```
  * exec → run a command inside a container
  * -it → interactive terminal

3. Navigate to Nginx default page location:

```
cd /usr/share/nginx/html

```

4. Edit index.html (you can use vi or echo for quick test):

```
echo "<h1>Hello from my Docker container!</h1>" > index.html

```
5. Exit the container:

```
exit

```
6. Refresh browser: http://localhost:8080 → should show your new page.
7. ![Modified-nginx-page](<Screenshot 2026-01-30 at 13.21.22.png>)
  

##  Run different container on different port
* You can run multiple containers without conflicts by using different host ports.

* Example: Run Apache HTTP server on port 8081:

```
docker run --name my-apache -p 8081:80 -d httpd

```

Now you have:

  * Nginx on http://localhost:8080

  * Apache on http://localhost:8081

Check running containers:
```
docker ps
```
  * Use docker ps -a to see all containers.

  * Use docker logs <container_name> to see container logs.

  * Use docker stop <container_name> and docker rm <container_name> to clean up.
# 4. Use Docker Hub to Host Custom Images
  ## Push host-custom-static-webpage Container Image to Docker Hub

  Objective:

  Create a custom Docker image containing a static web page and push it to Docker Hub so it can be reused and deployed anywhere.
  * Step 1: Create a Static Web Page
  Create a project directory:

  ```
  mkdir host-custom-static-webpage
  cd host-custom-static-webpage

  ```
  Create index.html:

  ```
  <!DOCTYPE html>
  <html>
  <head>
    <title>Sparta Docker Project</title>
  </head>
  <body>
    <h1>Host Custom Static Webpage</h1>
    <p>This page is served from a Docker container.</p>
  </body>
  </html>
  ```

  * Step 2: Create the Dockerfile
  ```
  FROM nginx:latest

  COPY index.html /usr/share/nginx/html/index.html

  EXPOSE 80
  ```
  * Step 3: Build the Docker Image
    ```
  docker build -t host-custom-static-webpage .
    ```
    Verify:
     ```
    docker images
   ```

  * Step 4: Test the Image Locally
    ```
  docker run -d -p 8080:80 --name static-web-test host-custom-static-webpage
    ```

    Open browser:
    ```
    http://localhost:8080
    ```
    Stop & remove test container:
     ```
    docker stop static-web-test
    docker rm static-web-test
     ```

    * Step 5: Tag the Image for Docker Hub
    Login: 
    ```
    docker login
  ```
  Push:
  ```
  docker push <dockerhub-username>/host-custom-static-webpage:latest
  ```

✔ Image is now publicly available on Docker Hub
✔ Can be pulled on any machine

 
## Automate Docker Image Creation Using a Dockerfile
Objective:
Use a Dockerfile to ensure consistent, repeatable image creation without manual container changes.
How Automation Works

Dockerfile defines:

* Base image

* Files to include

* Runtime configuration

* Image can be rebuilt at any time using a single command


Dockerfile Breakdown:
```
FROM nginx:latest
```
Uses official Nginx image
```
COPY index.html /usr/share/nginx/html/index.html
```

Replaces default Nginx page
```
EXPOSE 80
```
Documents container port
Automated Build Command
```
docker build -t host-custom-static-webpage .

```
This:

Pulls base image if needed

Copies files automatically

Produces a reusable image



* Benefits for the Sparta Project

  1. No manual configuration inside containers

  2. Version-controlled deployment process

  3. Same approach will be used for:

    * Node.js v20 app

    * MongoDB database

Essential for AWS deployment and CI/CD pipelines
## Dockerfile — Node.js v20 (template)
Use a two-stage Dockerfile (adjust entrypoint and build step to your app):
```
FROM node:20-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --legacy-peer-deps
COPY . .
RUN npm run build || true
FROM node:20-alpine
WORKDIR /usr/src/app
ENV NODE_ENV=production
COPY --from=builder /usr/src/app ./
RUN npm prune --production || true
EXPOSE 3000
CMD ["node","index.js"]
```
Build and run:
```zsh
docker build -t <USER>/sparta-node:latest .
docker run -d --name sparta-app -p 3000:3000 <USER>/sparta-node:latest
curl -sS http://localhost:3000
```

## Short notes / gotchas
- If `docker info` fails, ensure Docker Desktop is running.
- Use unique host ports if 3000/8080 are taken.
- Bind mounts on macOS may have permission/refresh quirks—use `:ro` for read-only mounts when appropriate.
- For private images, consider AWS ECR (next steps).

---


---

##  Task: Run and pull your first image — step-by-step (what to do and what to expect)

This section guides you through the exact steps in your terminal and explains what happens at each step. Use your macOS Terminal, iTerm2, or Git Bash on Windows.

1) Open a terminal

2) Get help from the `docker` command

```bash
docker --help
# or for a specific command
docker run --help
```
What this shows: the CLI help, flags and common options. If this fails with "Cannot connect to the Docker daemon", start Docker Desktop (macOS) and wait until it's running.

3) Show local Docker images

```bash
docker images
# or the newer format
docker image ls
```
Expected output: a table with columns REPOSITORY, TAG, IMAGE ID, CREATED, SIZE. If there are no local images you will see only the header or no rows.

4) Run the `hello-world` image (first run)

```bash
docker run hello-world
```
What happens under the hood:
- Docker checks if `hello-world:latest` exists locally.
  - If not present, the client requests the daemon to pull the image from Docker Hub.
  - The daemon downloads the image layers and stores them locally.
- The daemon creates a container from the image and runs the container's command.
- `hello-world` prints a message and exits. The container finishes and remains in the `exited` state (unless `--rm` is specified).

Expected output (abridged):
```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
...
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

5) Run it a second time

```bash
docker run hello-world
```
Expected difference:
- Docker will find the `hello-world:latest` image locally and will not need to pull it. The run will be faster because download is skipped.
- You will still see the same output from the container program.

Documented behaviour when image exists vs not:
- If the image does not exist locally:
  - `docker run` implicitly triggers a `docker pull` from the default registry (Docker Hub) and downloads the image layers.
  - Once download finishes, the image is present locally in the image store.
- If the image exists locally:
  - `docker run` uses the local copy. No network download is needed.
- If you explicitly `docker pull <image>` and the local cache is up-to-date, the pull will finish quickly — the daemon checks checksums and only downloads missing layers.

6) Optional: run with `--rm` and interactive examples

```bash
# remove the container automatically after exit
docker run --rm hello-world

# run an interactive alpine shell
docker run --rm -it alpine:latest sh
# try `cat /etc/os-release` then exit
```

7) Cleanup example

List all containers (including exited):
```bash
docker ps -a
```
Remove an exited container:
```bash
docker rm <container-id-or-name>
```
Remove local image (if you want to force re-download next time):
```bash
docker rmi hello-world:latest
```

---

##  What I have learned by completing this task:

- The conceptual difference between VMs and containers and when to use each.
- What a container image includes vs what a VM includes.
- How Docker composes images from layers and reuses cache across builds/pulls.
- How to inspect local images and containers and how `docker run` behaves when the image exists or not.
- Practical commands: `docker image ls`, `docker run`, `docker pull`, `docker ps -a`, `docker rm`, `docker rmi`, `docker exec`, `docker cp`, and when to use `--rm`.

---

