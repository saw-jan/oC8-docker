## Docker image for ownCloud 8

### build image

```bash
docker build -t <image-name> ./
```

### run the container

```bash
docker run -p 8080:80 <image-name>
```

Server will be available at `http://localhost:8080`
