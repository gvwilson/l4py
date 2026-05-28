# Regenerate .out files from .lean and .sh sources.
#
# Run `python bin/update-makefile.py` first to generate dependencies.mk,
# then `make` to rebuild any stale .out files.

OUTPUTS :=
-include dependencies.mk

.DEFAULT_GOAL := commands

# Keep .out files around when the command fails
.PRECIOUS: %.out

## commands: show available commands
commands:
	@grep -h -E '^##' ${MAKEFILE_LIST} \
	| sed -e 's/## //g' \
	| column -t -s ':'

## bib: Check bibliography entries
bib:
	@mccole bib

## clean: clean up generated and cache files
clean:
	@rm -f $(OUTPUTS) dependencies.mk
	@find . -type f -name '*~' -exec rm {} \;

## check: check code and project
check:
	@mccole check --src . --dst docs
	@typos *.md */*.md

## serve: serve generated HTML on port 8000
serve:
	@python -m http.server -d docs 8000

## site: build HTML
site:
	@mccole build --src . --dst docs
	@touch docs/.nojekyll

# build .out from .sh script
%.out: %.sh %.lean
	-cd $(dir $<) && bash $(notdir $<) > $(notdir $@) 2>&1

# build .out from .lean file
%.out: %.lean
	-cd $(dir $<) && lake env lean $(notdir $<) > $(notdir $@) 2>&1

## regen: regenerate outputs
regen: $(OUTPUTS)

## depend: regenerate dependencies file
depend:
	@python bin/update-makefile.py
