all: test

.PHONY: test
test:
	rm -rf dist
	rm -rf emacs.d/elpa/term-alert-1.3.0
	cask package
	cask install
	cask exec ert-runner
	test/test-interactive.sh
