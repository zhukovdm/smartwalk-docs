docs-mkdocs:
	rm -rf ./site && mkdocs build

docs-backend: docs-mkdocs
	cd $(PWD)/../smartwalk/app/backend && rm -rf ./docs && doxygen && mv ./docs/html $(PWD)/site/prg-backend

docs-frontend: docs-mkdocs
	cd $(PWD)/../smartwalk/app/frontend && rm -rf ./docs && npm run docs && mv ./docs $(PWD)/site/prg-frontend

docs: docs-backend docs-frontend
