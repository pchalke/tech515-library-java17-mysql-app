- [Running the Sparta Test App with Docker \& Docker Compose](#running-the-sparta-test-app-with-docker--docker-compose)
  - [Task: Run Sparta test app in a container](#task-run-sparta-test-app-in-a-container)
  - [Task: Research Docker Compose](#task-research-docker-compose)
  - [Task: Use Docker Compose to run app and database containers](#task-use-docker-compose-to-run-app-and-database-containers)



# Running the Sparta Test App with Docker & Docker Compose


## Task: Run Sparta test app in a container
1. Task: Run Sparta Test App in a Container
- Objective
- Containerise the Sparta test app using Node.js v20 so it can run consistently on any machine.
- Project Structure (Example)

```
sparta-test-app/
├── app/
│   ├── app.js
│   ├── package.json
│   └── package-lock.json
└── Dockerfile
```
- Dockerfile for Sparta Test App (docker file syntax)
- cd in the sparta-test-app folder and then create a dockerfile. docker file should always have capital 'D' Dockerfile

```
FROM node:20-alpine
<!-- Uses Node.js v20 on Alpine Linux (small image size). -->

WORKDIR /usr/src/app
<!-- Sets the working directory inside the container. -->

COPY app/ .
<!-- Copies the rest of the application code into the container. -->


RUN npm install
<!-- Installs dependencies. -->


EXPOSE 3000
<!-- Documents that the app listens on port 3000 (does not actually publish it). -->

CMD ["npm", "start", "app.js"]
<!-- Starts the app with Node. -->
<!-- there shouldnt be any space. all words should be in "" -->
```

- Build the Image

```
docker build -t sparta-test-app .
```

- Run the Container

```
docker run -d \
-p 3000:3000 \
--name sparta-app \
sparta-test-app

```
- Access in browser:

```
http://localhost:3000

```
![app-front-page](<Screenshot 2026-01-13 at 12.17.31.png>)

- Verify Container

```
docker ps
docker logs sparta-app

```

- Stop & Remove

```
docker stop sparta-app
docker rm sparta-app

```

##  Task: Research Docker Compose
* What is Docker Compose?

  - Docker Compose is a tool used to define and run multi-container Docker applications using a single YAML file.

* Why Docker Compose?

    * Without Compose:

        * Each container started manually

        * Manual networking

        * Hard to manage dependencies

* With Compose:

    * One command starts everything

    * Built-in networking

    * Clear service relationships

| Concept      | Description             |
| ------------ | ----------------------- |
| `services`   | Containers to run       |
| `build`      | Dockerfile to use       |
| `image`      | Image to pull           |
| `ports`      | Port mapping            |
| `depends_on` | Startup order           |
| `volumes`    | Persistent storage      |
| `networks`   | Container communication |

* Why Compose is Ideal for Sparta App?

  * App + MongoDB run together

  * Containers communicate via service names

  * Same setup locally and on AWS


##  Task: Use Docker Compose to run app and database containers
* Objective

  * Run:

  * Sparta Node.js app

  * MongoDB database
  * (Together using Docker Compose.)

* docker-compose.yml
  
```yaml
version: "3.8"

services:
  app:
    build: .
    container_name: sparta-app
    ports:
      - "3000:3000"
    environment:
      DB_HOST: "mongodb://mongo:27017"
    depends_on:
      - mongo

  mongo:
    image: mongo:7
    container_name: sparta-mongo
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db

volumes:
  mongo-data:

```

* How Containers Communicate

  * App connects to database using:

```
mongodb://mongo:27017

```

  * 'mongo' is the service name defined in docker-compose.yml.
  *  Docker Compose creates a private network automatically
  


*  Start the Application Stack

```
docker compose up -d

```
*  Verify Containers are Running

```
docker ps
docker logs sparta-app
```

*  Access the Application

``` 
http://localhost:3000
```
![Front-page-of-app](<Screenshot 2026-01-13 at 14.21.52.png>)

* Access the database

```
http://localhost:3000/posts

```
![Posts-page-of-app](<Screenshot 2026-01-13 at 16.25.38.png>)
  


*  Stop and Remove Containers

``` 
docker compose down

```
* (Optional: remove volumes)

```
docker compose down -v

```

* Benefits for AWS Deployment

    * Same Compose file can be adapted for:

    * EC2

    * ECS

    * Clear microservice separation

    * Infrastructure as code

