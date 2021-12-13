

# Testing locally

If it's a new major version check the documentation for the changes in `dhis.conf`
then test locally

Let's say we want to release a 2.33.8 version
```
./script/build 2.33.8
```
launch the docker compose

```
cd test
DHIS2_FULL_VERSION=2.33.8 docker-compose up
```
(note data isn't persisted on purpose)

then check

```
http://localhost:8080/
```

login with `admin` `district`

note for testing "FILESTORE_PROVIDER" related properties you can just install taskr in the dhis2 apps.

# Releasing an image via github workflow

Preferred method (better network connectivity compared to your home network)

https://github.com/BLSQ/ops-dhis2-images/actions/workflows/publish.yml

# Releasing an image locally

Let's say we want to release a 2.33.8 version
```
./script/build 2.33.8
```

if not done yet, you need to login 
```
docker login
```

then publish on dockerhub
```
./script/publish 2.33.8
```

test that image in staging or test environment



# ENV variables

| env variable          | default value  |  description                     |
|-----------------------|----------------|----------------------------------|
| DHIS_BASE_URL         |                |                                  |
| DATABASE_HOST         |                |                                  |
| DATABASE_NAME         |     | |
| DATABASE_PORT         |   5432         |                                  |
| DATABASE_NAME         |                |                                  |
| DATABASE_USER         |                |                                  |  
| DATABASE_PASSWORD     |                |                                  |
| DATABASE_OPTIONS      | sslmode=require | depending on how is pg configure you might want to override that (eg localhosting) |
| ENCRYPTION_PASSWORD   |                | |
| FILESTORE_PROVIDER    | aws-s3         | other possible value `filesystem`  |
| FILESTORE_BUCKET      |                | set to files if not S3\n if s3 note that older version don't support eu-central-1 |
| FILESTORE_LOCATION    |                | set to files if not S3                                 |
| FILESTORE_IDENTITY    |                |                                  |
| FILESTORE_SECRET      |                |                                  |
| DHIS_AUDIT_LOGGER     |   on           |                                  |
| DHIS_AUDIT_DB         |   on           |                                  |
| DHIS_AUDIT_MATRIX_METADATA | CREATE;UPDATE;DELETE;READ | |
| DHIS_AUDIT_MATRIX_TRACKER | CREATE;UPDATE;DELETE;READ | |
| DHIS_AUDIT_MATRIX_AGGREGATE | CREATE;UPDATE;DELETE;READ | |
| CACHE_EXPIRATION
| DEFAULT_LOG_LEVEL
| DHIS_LOG_LEVEL
| SPRING_LOG_LEVEL
| HAZELCAST_LOG_LEVEL


# Volumes

for local hosting you can override ./root/files

# Implementation details

* Different approach compared to the official images
  - don't rebuild the war files but use the official released war
  - allow config via env variables for most options (thanks to [dockerize](https://github.com/jwilder/dockerize))
  - don't force volumes by default
  - log to stdout and not files
  - use an embbeded tomcat war runner (no tomcat manager)
* Compared to a previous approach, moved the download of the war "outside" the dockerfile:
  - this increase the docker build context but 
  - allow faster build locally if you previously downloaded the war file (eg to test changes in dockerfile or templates).