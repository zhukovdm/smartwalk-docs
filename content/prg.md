# Programmer's guide

To ensure a gentle learning curve and easier participation in the project, see useful stuff below.

## Environment

Learn more about the development environment [here](./adm.md#development-environment).

## Project structure

```txt
.
|
|
|
|
|
```

## Backend architecture

Code documentation is at [dev-backend](https://zhukovdm.github.io/smartwalk-docs/dev-backend/).

## Frontend architecture

Code documentation is at [dev-frontend](https://zhukovdm.github.io/smartwalk-docs/dev-frontend/)

## OpenAPI endpoints

All The project uses standardized OpenAPI

Once the backend is up and running 

Swagger documentation is available [here](http://localhost:5017/swagger/index.html). Unfortunately, not all endpoints provide examples. Due to the statelessness of the backend to enable caching, search queries are represented as percent-encoded serialized JSON objects. Detailed information regarding their internal structure is given in the following JSON-schema files.
