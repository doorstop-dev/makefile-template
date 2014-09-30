# Project settings
PRJ_DIR := prj_dir      # Replace directory with a common distrobution point for the team
SPECS_NAME := PRJ-Specs # Replace with a customer-specific PRJ name
SPECS := specs          # Default "template" location of specifications

# virtualenv settings
ENV := env

# Flags for PHONY targets
DEPENDS_CI := $(ENV)/.depends-ci
DEPENDS_DEV := $(ENV)/.depends-dev
ALL := $(ENV)/.all

# Flags for targest ... modify for your project
SPECS_CHECK := $(SPECS)/.specs_check
SPECS_CHECK_FL := $(SPECS)/.specs_check_FL
SPECS_CHECK_SYSRS := $(SPECS)/.specs_check_SYSRS
SPECS_CHECK_CLHLR := $(SPECS)/.specs_check_CLHLR
SPECS_CHECK_HWHLR := $(SPECS)/.specs_check_HWHLR
SPECS_CHECK_MEHLR := $(SPECS)/.specs_check_MEHLR
SPECS_CHECK_SWHLR := $(SPECS)/.specs_check_SWHLR
EXCEL_CHECK_FL := tmp/.excel_check_FL
EXCEL_CHECK_SYSRS := tmp/.excel_check_SYSRS
EXCEL_CHECK_CLHLR := tmp/.excel_check_CLHLR
EXCEL_CHECK_HWHLR := tmp/.excel_check_HWHLR
EXCEL_CHECK_MEHLR := tmp/.excel_check_MEHLR
EXCEL_CHECK_SWHLR := tmp/.excel_check_SWHLR


# OS-specific paths (detected automatically from the system Python)
PLATFORM := $(shell python -c 'import sys; print(sys.platform)')
ifeq ($(OS),Windows_NT)
	SYS_PYTHON := C:\\Python33\\python.exe
	SYS_VIRTUALENV := C:\\Python33\\Scripts\\virtualenv.exe
	BIN := $(ENV)/Scripts
	OPEN := cmd /c start
	# https://bugs.launchpad.net/virtualenv/+bug/449537
	export TCL_LIBRARY=C:\\Python33\\tcl\\tcl8.5
else
	SYS_PYTHON := python3
	SYS_VIRTUALENV := virtualenv
	BIN := $(ENV)/bin
	ifneq ($(findstring cygwin, $(PLATFORM)), )
		OPEN := cygstart
	else
		OPEN := open
	endif
endif

# virtualenv executables
PYTHON := $(BIN)/python
PIP := $(BIN)/pip
EASY_INSTALL := $(BIN)/easy_install
RST2HTML := $(PYTHON) $(BIN)/rst2html.py
PDOC := $(PYTHON) $(BIN)/pdoc
DOORSTOP := $(BIN)/doorstop

VERSION := $(shell python $(SPECS)/__version__.py)

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
	# $(PIP) install --upgrade doorstop # install released
	$(PIP) install https://github.com/jacebrowning/doorstop/archive/master.zip # install master-dev
	# $(PIP) install https://github.com/jacebrowning/doorstop/archive/f5ee2b9dc1e3bb4483d9b582a86842b227074a81.zip # install test-hash
	touch $(DEPENDS_CI)  # flag to indicate dependencies are installed

.PHONY: .depends-dev
.depends-dev: env Makefile $(DEPENDS_DEV)
$(DEPENDS_DEV): Makefile
	$(PIP) install --upgrade docutils
	touch $(DEPENDS_DEV)  # flag to indicate dependencies are installed

# Documentation ##############################################################

.PHONY: specs
specs: .depends-ci docs/html/index.html
docs/html/index.html: $(shell find $(SPECS) -name '*.yml')
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
	$(OPEN) docs/html/index.html
	$(OPEN) docs/README-github.html

# Static Analysis ############################################################

.PHONY: reqcheck
reqcheck: doorstop

.PHONY: doorstop
doorstop: .depends-ci $(SPECS_CHECK)
$(SPECS_CHECK): $(SPECS)/__version__.py $(shell find $(SPECS) -name '*.yml')
	$(DOORSTOP) --no-level-check
	touch $(SPECS_CHECK)

# Worker Scripts #############################################################

.PHONY: excel-export
excel-export: .depends-ci $(SPECS_CHECK_FL) $(SPECS_CHECK_SYSRS) $(SPECS_CHECK_CLHLR) $(SPECS_CHECK_HWHLR) $(SPECS_CHECK_MEHLR) $(SPECS_CHECK_SWHLR)
$(SPECS_CHECK_FL): $(shell find $(SPECS)/FeatureList -name '*.yml')
	$(DOORSTOP) export FL tmp/FL.xlsx --xlsx
	touch $(SPECS_CHECK_FL)
	touch $(EXCEL_CHECK_FL)
$(SPECS_CHECK_SYSRS): $(shell find $(SPECS)/SYSRS -name '*.yml')
	$(DOORSTOP) export SYSRS tmp/SYSRS.xlsx --xlsx
	touch $(SPECS_CHECK_SYSRS)
	touch $(EXCEL_CHECK_SYSRS)
$(SPECS_CHECK_CLHLR): $(shell find $(SPECS)/CLRS -name '*.yml')
	$(DOORSTOP) export CLHLR tmp/CLHLR.xlsx --xlsx
	touch $(SPECS_CHECK_CLHLR)
	touch $(EXCEL_CHECK_CLHLR)
$(SPECS_CHECK_HWHLR): $(shell find $(SPECS)/HWRS -name '*.yml')
	$(DOORSTOP) export HWHLR tmp/HWHLR.xlsx --xlsx
	touch $(SPECS_CHECK_HWHLR)
	touch $(EXCEL_CHECK_HWHLR)
$(SPECS_CHECK_MEHLR): $(shell find $(SPECS)/MERS -name '*.yml')
	$(DOORSTOP) export MEHLR tmp/MEHLR.xlsx --xlsx
	touch $(SPECS_CHECK_MEHLR)
	touch $(EXCEL_CHECK_MEHLR)
$(SPECS_CHECK_SWHLR): $(shell find $(SPECS)/SWRS -name '*.yml')
	$(DOORSTOP) export SWHLR tmp/SWHLR.xlsx --xlsx
	touch $(SPECS_CHECK_SWHLR)
	touch $(EXCEL_CHECK_SWHLR)

.PHONY: excel-import
excel-import: .depends-ci $(EXCEL_CHECK_FL) $(EXCEL_CHECK_SYSRS) $(EXCEL_CHECK_CLHLR) $(EXCEL_CHECK_HWHLR) $(EXCEL_CHECK_MEHLR) $(EXCEL_CHECK_SWHLR)
$(EXCEL_CHECK_FL): tmp/FL.xlsx
	$(DOORSTOP) import tmp/FL.xlsx FL
	touch $(EXCEL_CHECK_FL)
$(EXCEL_CHECK_SYSRS): tmp/SYSRS.xlsx
	$(DOORSTOP) import tmp/SYSRS.xlsx SYSRS
	touch $(EXCEL_CHECK_SYSRS)
$(EXCEL_CHECK_CLHLR): tmp/CLHLR.xlsx
	$(DOORSTOP) import tmp/CLHLR.xlsx CLHLR
	touch $(EXCEL_CHECK_CLHLR)
$(EXCEL_CHECK_HWHLR): tmp/HWHLR.xlsx
	$(DOORSTOP) import tmp/HWHLR.xlsx HWHLR
	touch $(EXCEL_CHECK_HWHLR)
$(EXCEL_CHECK_MEHLR): tmp/MEHLR.xlsx
	$(DOORSTOP) import tmp/MEHLR.xlsx MEHLR
	touch $(EXCEL_CHECK_MEHLR)
$(EXCEL_CHECK_SWHLR): tmp/SWHLR.xlsx
	$(DOORSTOP) import tmp/SWHLR.xlsx SWHLR
	touch $(EXCEL_CHECK_SWHLR)

# Testing ####################################################################


# Cleanup ####################################################################

.PHONY: clean
clean: .clean-doc .clean-specs-release
	rm -rf $(ALL)

.PHONY: clean-all
clean-all: clean .clean-env

.PHONY: .clean-env
.clean-env:
	rm -rf $(ENV)

.PHONY: .clean-doc
.clean-doc:
	rm -rf docs README.rst $(SPECS)/.specs_check* tmp

.PHONY: .clean-specs-release
.clean-specs-release:
	rm -rf specs-release

# Release ####################################################################

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
live: .git-no-changes reqcheck doc
	rm -fr $(PRJ_DIR)/tmp-specs
	cp -fr docs $(PRJ_DIR)/tmp-specs
	rm -fr $(PRJ_DIR)/Specifications
	mv -f $(PRJ_DIR)/tmp-specs $(PRJ_DIR)/Specifications

.PHONY: specs-release
specs-release: .git-no-changes reqcheck specs
	rm -fr specs-release/specs
	mkdir -p specs-release
	zip -rv specs-release/$(SPECS_NAME)-$(VERSION).zip docs/html -i "*.html"

.PHONY: release
release: specs-release
	git tag -a $(VERSION) -m '"Release of version $(VERSION)"'
	git push --tags

# System Installation ########################################################
