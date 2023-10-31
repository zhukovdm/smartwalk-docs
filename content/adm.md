# Administrator guide

[**Data preparation**](#data-preparation) provides a step-by-step procedure of how to integrate data from *six* different sources and prepare them for running SmartWalk.

Once data are ready, read [**Running the app**](#running-the-app) to learn how to get the application up and running in development and production settings.

If something is broken or not working as expected, you might find [**Troubleshooting**](#troubleshooting) helpful before searching for a solution on the Web.

## Data preparation

This section explains how to prepare data for two system components: the [database](#entity-storage-and-index) and the [routing engine](#routing-engine).

!!! warning
    The complexity of extracting and building data structures depends on the size of a particular region and might be time- and resource-consuming, especially when processing `OSM` dumps.

### Prerequisites

Ensure that the following programs are installed on the target system.

- `bash`
- `docker`
- `dotnet-sdk-6.0`
- `git`
- `make`
- `node v18.x` (can be installed using [nvm](https://github.com/nvm-sh/nvm#install--update-script))
- `wget`

!!! note
    If mentioned, preserve proper versions because of the library dependencies.

**ADVICE:** All docker-related commands require the current user to be a member of the `docker` group to avoid using `sudo` (or similar) repeatedly, see details at [Manage Docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user).

### Environment

Clone the repository and navigate to the `data` folder:

```bash
git clone --recurse-submodules https://github.com/zhukovdm/smartwalk.git
cd ./smartwalk/data/
```

Decide which part of the world you are interested in. Download `pbf`-file at [Geofabrik](https://download.geofabrik.de/), and store it in `./assets/osm-maps/`. As an example, the following command makes use of the `wget` utility to download the latest dump of the Czech Republic:

```bash
wget \
  -O ./assets/osm-maps/czech-republic-latest.osm.pbf \
  https://download.geofabrik.de/europe/czech-republic-latest.osm.pbf
```

Open `Makefile` and set the value of `REGION_FILE` accordingly. Some of the `OSM` dumps are quite large and additional refinement might be necessary. There are four additional variables `REGION_X`, where suffix `X` can be any of `W` (West), `N` (North), `E` (East), or `S` (South), defining a bounding box. Entities outside the bounding box are filtered out. To switch off filtering, set `W=-180.0`, `N=85.06`, `E=180.0`, and `S=-85.06` (see [EPSG3857](https://epsg.io/3857) for details).

Create folders necessary for storing data and restore project dependencies:

```bash
make init
```

### Routing engine

Build data structure for the routing engine:

```bash
make routing-engine
```

The command pulls [this docker image](https://hub.docker.com/r/osrm/osrm-backend/) and builds a search structure in several consecutive phases. The results are stored in the `./assets/routing-engine/`.

**ADVICE:** An instance of the OSRM backend is able to load [only one](https://help.openstreetmap.org/questions/64867/osrm-routed-for-multiple-countries) `osrm`-file at a time. This limi- tation can be overcome via merging (see [osmosis](https://gis.stackexchange.com/a/242880)).

**ADVICE:** It is possible to extract routing data for several regions and keep all files in the same folder as long as the original `pbf`-files have distinct names. Use [environment variables](#environment-variables) to select a part of the world on engine start.

### Entity storage and index

Start up a [containerized](https://hub.docker.com/_/mongo/) database instance:

```bash
docker compose -f docker-compose.yaml up -d
```

**ADVICE:** Enter `docker container ls` repeatedly to print out the list of existing containers. Wait until `smartwalk-database` is healthy.

Clean up all previous data, create new collections and indexes:

```bash
make database-init
```

Obtain the most popular `OSM` keys from [Taginfo](https://taginfo.openstreetmap.org/taginfo/apidoc) and store results in `./assets/taginfo/`:

```bash
make taginfo
```

**ADVICE:** A list of tags can be extended by altering `Makefile`, although this is not enough to enable their full potential. The [constructor](https://github.com/zhukovdm/smartwalk/blob/fab346ac73f43be063b7e16d4f2c5f060e38ecfc/data/osm/KeywordExtractor.cs#L23-L53) of `KeywordExtractor` shall reflect changes as well. <u>Never remove</u> tags from the list as it may brake things unexpectedly. Modifying tag list is not a typical operation and may require deeper knowledge of the system.

Extract entities from the `pbf`-file:

```bash
make database-osm
```

As part of the procedure, the routine makes a `GET` request to the [Overpass API](https://overpass-api.de/api/interpreter). The connection is configured to time out after 100s, but the server usually responds within 10s at most.

**ADVICE:** To make queries feasible for the external API, the selected bounding box is divided into smaller squares. The recipe has two switches `--rows` and `--cols` defining the grid.

Create stubs for entities that exist in the [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page) knowledge graph:

```bash
make database-wikidata-create
```

The script attempts to fetch data from the SPARQL endpoint. Requests may time out after *one* minute. Large regions are more likely to result in failures. Hence, the numeric constants were specifically chosen for the test setup and may not be suitable for other cases.

**ADVICE:** The recipe has `--rows` and `--cols` switches with functionality similar to `database-osm`.

Enrich existing entities by information from [Wikidata](https://www.wikidata.org/wiki/Wikidata:Main_Page):

```bash
make database-wikidata-enrich
```

Enrich existing entities by information from [DBPedia](https://www.dbpedia.org/about/) knowledge graph:

```bash
make database-dbpedia
```

Collect supporting data to aid autocomplete functionality:

```bash
make advice
```

Finally, stop the database instance:

```bash
docker compose -f docker-compose.yaml down
```

All relevant data are stored in `./assets/database`.

### Idempotent updates

The system supports [idempotent](https://en.wikipedia.org/wiki/Idempotence#Idempotent_functions) updates to incorporate new versions of datasets.

It is possible to re-run blue-highlighted commands with no impact on data integrity. The programs are designed to update defined properties without replacing entities existing in the database.

`advice` should be re-generated whenever the database state is altered.

![command dependencies](./img/data-prep-deps.drawio.svg)

### Dumping and restoring

[place.json](https://www.dropbox.com/scl/fi/25e8u3t5mdx37qn3ncd7t/place.json?rlkey=58cw4mdcsyz3z77tuzzu7qspo&dl=0) and [keyword.json](https://www.dropbox.com/scl/fi/cdh3zngnybptvn0goc46e/keyword.json?rlkey=5655oq6lcom7fjjo28650tbbb&dl=0)

Once two previous phases are done, the `./assets/` folder contains all data necessary for running an instance of the application. Create self-contained docker images to optimize and simplify testing.

```bash
docker build -f ./Dockerfile.database -t smartwalk-database
docker build -f ./Dockerfile.routing-engine -t smartwalk-routing-engine
```

## Running the app

The application consists of $4$ interconnected containers.

| Container | Mapping         | Role                        |
|-----------|-----------------|-----------------------------|
| proxy     | localhost:3000  | Reverse proxy, static files |
| backend   | -               | Application logic           |
| database  | localhost:27017 | Entity store, entity index  |
| routing   | -               | Routing engine              |

Note that the database container exposes connection for easier manual diagnostic.

```bash
make prod
```

To stop production environment, enter `make prod-stop`.

### Environment variables

`SMARTWALK_MONGO_CONN_STR`, `SMARTWALK_OSRM_BASE_URL`,

http://localhost:5017/swagger/index.html

## Troubleshooting

### WSL runs out of memory

- If you use `WSL` and run out of memory, Windows may unexpectedly terminate the entire. To prevent Windows from stopping, try to extend the swap file by setting `swap=XXGB` in the `.wslconfig`, see details [here](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#example-wslconfig-file).

### A container is unhealthy or starting

In case any of the containers is unhealthy or starting for too long (healthcheck has failed repeatedly), replace `[container_name]` placeholder by the name of a problematic instance and press `Enter` to find out the reason.

```bash
$ docker container ls -a

CONTAINER ID   IMAGE                    ...   NAMES
...            ...                      ...   ...
377fe35d4472   smartwalk/proxy:v1.0.0   ...   smartwalk-proxy
...            ...                      ...   ...

$ docker inspect --format "{{json .State.Health }}" [container_name]
```

### Nothing seems to help

If nothing helps, clean up the system (remove images and cached build files) and start from scratch. Use the last command with caution as it may introduce undesired changes into your docker host, read about side effects [here](https://docs.docker.com/engine/reference/commandline/system_prune/).

```bash
$ docker image rm smartwalk/
$ docker system prune
```
