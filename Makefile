.PHONY: all
all: dist/index.css dist/index.html dist/index.js

.PHONY: clean
clean:
	rm dist/*

dist/index.css: src/Main.elm src/index.css src/index.html
	npx postcss src/index.css -o dist/index.css

dist/index.html: src/index.html
	npx html-minifier src/index.html --collapse-whitespace --minify-js -o dist/index.html

dist/index.js: src/Main.elm
	elm make src/Main.elm --optimize --output dist/temp.js
	npx uglifyjs dist/temp.js --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | npx uglifyjs --mangle --output dist/index.js
	rm dist/temp.js
