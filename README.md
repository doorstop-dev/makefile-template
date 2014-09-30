
**NOTE: This repository contains customer data an cannot be made public.**

-----

[Customer] - [Project] - Requirements Management
=======================================================

This repo is used by DornerWorks to manage project documentation:

* [Document List](html/index.html)

This repo also contains requirements in the format expected by [Doorstop](https://pypi.python.org/pypi/doorstop).

`Doorstop` checks for generic and project-specific issues in the requirements.

`Doorstop` also checks that each requirement is in the correct review status for both changes in content and linked content.


Getting Started
===============

Requirements
------------
* [bootstrap.bat](http://arnie/packages/bootstrap/bootstrap.bat)
* Git
    * Windows: http://cygwin.com/install.html
* GNU Make:
    * Windows: http://cygwin.com/install.html
    * Mac: https://developer.apple.com/xcode
    * Linux: http://www.gnu.org/software/make (likely already installed)


Installation
------------
- [bootstrap.bat](http://arnie/packages/bootstrap/bootstrap.bat) will install Python
and Windows-based dependencies. It will then download [bootstrap.py](http://arnie/packages/bootstrap/bootstrap.py) which
will install other dependencies through `pip`.
- Install Git for your environment.
- Clone the Git repo and edit the requirements.
- The Makefile will create a virtualenv and take care of all dependencies related to automatic checks.


Basic Usage
===========

Use the provided Makefile to generate files and check requirements validity.

The `Doorstop` tool is used to generate requirements in the `specs/` directory.

The following items will be created in the directories:

* env/ - a Python `virtualenv` to control the tool configuration for development
* tmp/ - directory to store exported Excel files
* docs/ - directory for generated document files
* specs-release/ - directory for *.zip generated from docs


For Developers
================

Requirements
------------

* GNU Make:
    * Windows: http://cygwin.com/install.html
    * Mac: https://developer.apple.com/xcode
    * Linux: http://www.gnu.org/software/make (likely already installed)
* virtualenv: https://pypi.python.org/pypi/virtualenv#installation
* Pandoc: http://johnmacfarlane.net/pandoc/installing.html
* Graphviz: http://www.graphviz.org/Download.php


Requirements Management
-----------------------

Edit Documents (see `doorstop` for details)

    $ source env/Scripts/activate
    $ doorstop edit [Doc-Prefix] --xlsx
    $ [edit] [save/close] [follow Y|N for import]
    $ git [add/commit]
    $ deactivate

Validate Traceability:

    $ make reqcheck

View Documentation:

    $ make read

Release Specifications:

    $ [edit] specs/__version__.py
    $ git [add/commit]
    $ make release
