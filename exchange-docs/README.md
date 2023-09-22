## Run docker container

```
docker build -t wsmm-api .
docker run --name wsmm-api -dp 127.0.0.1:8081:8081 wsmm-api
```