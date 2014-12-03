# Project settings
## Replace directory with a common distrobution point for the team
PRJ_DIR := prj_dir
## Replace with a customer-specific PRJ name
PRJ_NAME := prj_name

# virtualenv settings
ENV := env

# Flags for PHONY targets
DEPENDS_CI := $(ENV)/.depends-ci
DEPENDS_DEV := $(ENV)/.depends-dev
ALL := $(ENV)/.all

# Flags for targest ... modify for your project
SPECS_CHECK_FL := specs/.specs_check_FL
SPECS_CHECK_SYSRS := specs/.specs_check_SYSRS
SPECS_CHECK_CLHLR := specs/.specs_check_CLHLR
SPECS_CHECK_HWHLR := specs/.specs_check_HWHLR
SPECS_CHECK_MEHLR := specs/.specs_check_MEHLR
SPECS_CHECK_SWHLR := specs/.specs_check_SWHLR
EXCEL_CHECK_FL := xlsx/.excel_check_FL
EXCEL_CHECK_SYSRS := xlsx/.excel_check_SYSRS
EXCEL_CHECK_CLHLR := xlsx/.excel_check_CLHLR
EXCEL_CHECK_HWHLR := xlsx/.excel_check_HWHLR
EXCEL_CHECK_MEHLR := xlsx/.excel_check_MEHLR
EXCEL_CHECK_SWHLR := xlsx/.excel_check_SWHLR


# OS-specific paths (detected automatically from the system Python)
PLATFORM := $(shell python -c 'import sys; print(sys.platform)')
ifeq ($(OS),Windows_NT)
	SYS_PYTHON := C:\\Python33\\python.exe
	SYS_VIRTUALENV := C:\\Python33\\Scripts\\virtualenv.exe
	BIN := $(ENV)/Scripts
	OPEN := cmd /c start
	FIND := C:\\cygwin\\bin\\find.exe
	# https://bugs.launchpad.net/virtualenv/+bug/449537
	export TCL_LIBRARY=C:\\Python33\\tcl\\tcl8.5
else
	SYS_PYTHON := python3
	SYS_VIRTUALENV := virtualenv
	BIN := $(ENV)/bin
	ifneq ($(findstring cygwin, $(PLATFORM)), )
		OPEN := cygstart
		FIND := find
	else
		OPEN := open
		FIND := find
	endif
endif

# virtualenv executables
PYTHON := $(BIN)/python
PIP := $(BIN)/pip
EASY_INSTALL := $(BIN)/easy_install
RST2HTML := $(PYTHON) $(BIN)/rst2html.py
PDOC := $(PYTHON) $(BIN)/pdoc
DOORSTOP := $(BIN)/doorstop

VERSION := $(shell python __version__.py)
BRANCH := $(shell git rev-parse --symbolic-full-name --abbrev-ref HEAD)
HASH := $(shell git rev-parse HEAD)
HASH8 := $(shell git rev-parse --short=8 HEAD)

# Main Targets ###############################################################

.PHONY: all
all: depends reqcheck doc $(ALL)
$(ALL):
	touch $(ALL)  # flag to indicate all setup steps were successful

.PHONY: ci
ci: reqcheck live

# Development Installation ###################################################

.PHONY: env
env: $(PIP)
$(PIP):
	$(SYS_VIRTUALENV) --python $(SYS_PYTHON) $(ENV)

.PHONY: depends
depends: .depends-ci .depends-dev

.PHONY: .depends-ci
.depends-ci: env Makefile $(DEPENDS_CI)
$(DEPENDS_CI): Makefile
	- $(PIP) uninstall doorstop --yes
	#=======================
	# install released
	# $(PIP) install --upgrade doorstop
	#=======================
	# install master-release
	# $(PIP) install https://github.com/jacebrowning/doorstop/archive/master.zip
	#=======================
	# install master-dev
	$(PIP) install https://github.com/jacebrowning/doorstop/archive/develop.zip
	#=======================
	# install test-hash
	# $(PIP) install https://github.com/jacebrowning/doorstop/archive/f5ee2b9dc1e3bb4483d9b582a86842b227074a81.zip
	#=======================
	touch $(DEPENDS_CI)  # flag to indicate dependencies are installed

.PHONY: .depends-dev
.depends-dev: env Makefile $(DEPENDS_DEV)
$(DEPENDS_DEV): Makefile
	$(PIP) install --upgrade docutils
	touch $(DEPENDS_DEV)  # flag to indicate dependencies are installed

# Documentation ##############################################################

.PHONY: specs
specs: .depends-ci docs/html/index.html
docs/html/index.html: $(shell $(FIND) specs -name '*.yml')
	rm -rf docs/html
	$(DOORSTOP) publish all docs/html --no-body-levels

.PHONY: readme
readme: .depends-dev docs/README-github.html docs/README-pypi.html
docs/README-github.html: README.md
	pandoc -f markdown_github -t html -o docs/README-github.html README.md
docs/README-pypi.html: README.rst
	$(RST2HTML) README.rst docs/README-pypi.html
README.rst: README.md
	pandoc -f markdown_github -t rst -o README.rst README.md

.PHONY: doc
doc: specs readme

.PHONY: read
read: doc
	$(OPEN) docs/README-github.html
	$(OPEN) docs/html/index.html

# Static Analysis ############################################################

.PHONY: reqcheck
reqcheck: doorstop

.PHONY: doorstop
doorstop: .depends-ci
	# ====================================
	# Implement during initial development ... displays WARNING's
	$(DOORSTOP) --no-level-check
	# ====================================
	# Implement during maintenance and formal change control ... WARNING's cause ERROR's
	# $(DOORSTOP) --no-level-check --error-all

# Worker Scripts #############################################################

.PHONY: excel-export
excel-export: .depends-ci $(SPECS_CHECK_FL) $(SPECS_CHECK_SYSRS) $(SPECS_CHECK_CLHLR) $(SPECS_CHECK_HWHLR) $(SPECS_CHECK_MEHLR) $(SPECS_CHECK_SWHLR)
$(SPECS_CHECK_FL): $(shell $(FIND) specs/FeatureList -name '*.yml')
	$(DOORSTOP) export FL xlsx/FL.xlsx --xlsx
	touch $(SPECS_CHECK_FL)
	touch $(EXCEL_CHECK_FL)
$(SPECS_CHECK_SYSRS): $(shell $(FIND) specs/SYSRS -name '*.yml')
	$(DOORSTOP) export SYSRS xlsx/SYSRS.xlsx --xlsx
	touch $(SPECS_CHECK_SYSRS)
	touch $(EXCEL_CHECK_SYSRS)
$(SPECS_CHECK_CLHLR): $(shell $(FIND) specs/CLRS -name '*.yml')
	$(DOORSTOP) export CLHLR xlsx/CLHLR.xlsx --xlsx
	touch $(SPECS_CHECK_CLHLR)
	touch $(EXCEL_CHECK_CLHLR)
$(SPECS_CHECK_HWHLR): $(shell $(FIND) specs/HWRS -name '*.yml')
	$(DOORSTOP) export HWHLR xlsx/HWHLR.xlsx --xlsx
	touch $(SPECS_CHECK_HWHLR)
	touch $(EXCEL_CHECK_HWHLR)
$(SPECS_CHECK_MEHLR): $(shell $(FIND) specs/MERS -name '*.yml')
	$(DOORSTOP) export MEHLR xlsx/MEHLR.xlsx --xlsx
	touch $(SPECS_CHECK_MEHLR)
	touch $(EXCEL_CHECK_MEHLR)
$(SPECS_CHECK_SWHLR): $(shell $(FIND) specs/SWRS -name '*.yml')
	$(DOORSTOP) export SWHLR xlsx/SWHLR.xlsx --xlsx
	touch $(SPECS_CHECK_SWHLR)
	touch $(EXCEL_CHECK_SWHLR)

.PHONY: excel-import
excel-import: .depends-ci $(EXCEL_CHECK_FL) $(EXCEL_CHECK_SYSRS) $(EXCEL_CHECK_CLHLR) $(EXCEL_CHECK_HWHLR) $(EXCEL_CHECK_MEHLR) $(EXCEL_CHECK_SWHLR)
$(EXCEL_CHECK_FL): xlsx/FL.xlsx
	$(DOORSTOP) import xlsx/FL.xlsx FL
	touch $(EXCEL_CHECK_FL)
$(EXCEL_CHECK_SYSRS): xlsx/SYSRS.xlsx
	$(DOORSTOP) import xlsx/SYSRS.xlsx SYSRS
	touch $(EXCEL_CHECK_SYSRS)
$(EXCEL_CHECK_CLHLR): xlsx/CLHLR.xlsx
	$(DOORSTOP) import xlsx/CLHLR.xlsx CLHLR
	touch $(EXCEL_CHECK_CLHLR)
$(EXCEL_CHECK_HWHLR): xlsx/HWHLR.xlsx
	$(DOORSTOP) import xlsx/HWHLR.xlsx HWHLR
	touch $(EXCEL_CHECK_HWHLR)
$(EXCEL_CHECK_MEHLR): xlsx/MEHLR.xlsx
	$(DOORSTOP) import xlsx/MEHLR.xlsx MEHLR
	touch $(EXCEL_CHECK_MEHLR)
$(EXCEL_CHECK_SWHLR): xlsx/SWHLR.xlsx
	$(DOORSTOP) import xlsx/SWHLR.xlsx SWHLR
	touch $(EXCEL_CHECK_SWHLR)

# Testing ####################################################################


# Cleanup ####################################################################

.PHONY: clean
clean: .clean-doc .clean-zips
	rm -rf $(ALL)

.PHONY: clean-all
clean-all: clean .clean-env

.PHONY: .clean-env
.clean-env:
	rm -rf $(ENV)

.PHONY: .clean-doc
.clean-doc:
	rm -rf docs README.rst specs/.specs_check* xlsx

.PHONY: .clean-zips
.clean-zips:
	rm -rf zips

# Release ####################################################################

.PHONY: .prj_dir-exists
.prj_dir-exists:
	@if [ -d "$(PRJ_DIR)" ];         \
	then                                          \
		echo Project Directory exists...;        \
	else                                          \
		echo ERROR: Project Directory does NOT exists!;   \
		exit -1;                                  \
	fi;

.PHONY: .git-no-changes
.git-no-changes:
	@if git diff --name-only --exit-code;         \
	then                                          \
		echo Git working copy is clean...;        \
	else                                          \
		echo ERROR: Git working copy is dirty!;   \
		echo Commit your changes and try again.;  \
		exit -1;                                  \
	fi;

.PHONY: live
live: .prj_dir-exists .git-no-changes reqcheck excel-export doc
	#=========================
	# Shared Project Directory
	rm -fr $(PRJ_DIR)/tmp-specs-$(BRANCH)
	mkdir $(PRJ_DIR)/tmp-specs-$(BRANCH)
	cp -fr docs $(PRJ_DIR)/tmp-specs-$(BRANCH)
	cp -f xlsx/*.xlsx $(PRJ_DIR)/tmp-specs-$(BRANCH)
	cp -fr tests $(PRJ_DIR)/tmp-specs-$(BRANCH)
	cp -fr design $(PRJ_DIR)/tmp-specs-$(BRANCH)
	cp -fr reviews $(PRJ_DIR)/tmp-specs-$(BRANCH)
	rm -fr $(PRJ_DIR)/Specifications-$(BRANCH)
	mv -f $(PRJ_DIR)/tmp-specs-$(BRANCH) $(PRJ_DIR)/Documentation-$(BRANCH)
	#=========================
	# Google-Drive/Dropbox Directory
	# mkdir -p $(PRJ_DIR)/$(BRANCH)/Specs
	# mkdir -p $(PRJ_DIR)/$(BRANCH)/Tests
	# mkdir -p $(PRJ_DIR)/$(BRANCH)/Design
	# mkdir -p $(PRJ_DIR)/$(BRANCH)/Reviews
	# rm -f $(PRJ_DIR)/$(BRANCH)/*.hash
	# cp -fr docs/* $(PRJ_DIR)/$(BRANCH)/Specs
	# cp -f xlsx/*.xlsx $(PRJ_DIR)/$(BRANCH)/Specs
	# cp -fr tests/* $(PRJ_DIR)/$(BRANCH)/Tests
	# cp -fr design/* $(PRJ_DIR)/$(BRANCH)/Design
	# cp -fr reviews/* $(PRJ_DIR)/$(BRANCH)/Reviews
	# touch $(PRJ_DIR)/$(BRANCH)/$(HASH).hash


.PHONY: zips
zips: .git-no-changes reqcheck excel-export doc
	mkdir -p zips
	zip -rv zips/$(PRJ_NAME)-Specs-$(BRANCH)-$(VERSION).zip docs -i *.html
	zip -v zips/$(PRJ_NAME)-Specs-$(BRANCH)-$(VERSION).zip xlsx/* -i *.xlsx
	zip -rv zips/$(PRJ_NAME)-Design-$(BRANCH)-$(VERSION).zip design
	zip -rv zips/$(PRJ_NAME)-Tests-$(BRANCH)-$(VERSION).zip tests
	zip -rv zips/$(PRJ_NAME)-Reviews-$(BRANCH)-$(VERSION).zip reviews

.PHONY: archive
archive: .git-no-changes
	mkdir -p zips
	git archive --format zip --output zips/$(PRJ_NAME)-Repo-$(BRANCH)-$(VERSION)-$(HASH8).zip $(BRANCH)

.PHONY: release
release: zips archive
	git tag -a $(VERSION) -m '"Release of version $(VERSION)"'
	git push --tags

# System Installation ########################################################
