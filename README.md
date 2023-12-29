# SmartWalk Docs

This repository contains the documentation for [SmartWalk](https://www.github.com/zhukovdm/smartwalk), a web application for keyword-aware walking route search.

## Serve

View the documentation locally (with hot reload) at http://127.0.0.1:8000/:

```bash
$ mkdocs serve
```

## Deploy

Clone the [SmartWalk](https://github.com/zhukovdm/smartwalk.git) repository into `../`.

Restore dependencies:

```bash
$ npm ci
```

Generate static files into the `./site/` folder:

```bash
$ make docs
```

Deploy files in the `./site/` folder to GitHub:

```bash
$ npm run deploy
```
