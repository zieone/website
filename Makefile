push: build
	rsync -v public/* zie@zie.one:/var/www/htdocs/www.zie.one/
build:
	hugo
serve:
	 hugo server -D --cleanDestinationDir --navigateToChanged --renderToDisk --disableFastRender --destination public/

.PHONY: push build serve
