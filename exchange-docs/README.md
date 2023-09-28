## Run docker container

```
docker build -t wsmm-api .
docker run --name wsmm-api -dp 127.0.0.1:8081:8081 wsmm-api
```

Note:
You need to set up next env variables in container to make salesforce connection work

```
SALESFORCE_USERNAME
SALESFORCE_PASSWORD 
SALESFORCE_SECURITY_TOKEN
```