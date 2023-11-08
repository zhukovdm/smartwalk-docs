# SmartWalk Docs

# Serve

View the documentation locally (with hot reload) at http://127.0.0.1:8000/:

```bash
mkdocs serve
```

## Deploy

Clone [smartwalk](https://github.com/zhukovdm/smartwalk.git) repository into `../`.

Restore dependencies:

```bash
npm ci
```

Generate static files into the `./site` folder:

```bash
make docs
```

Deploy `./site` with static files to GitHub:

```bash
npm run deploy
```
