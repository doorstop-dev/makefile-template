
**!! IMPORTANT !!**
*If this template is used for a customer project, the following note should be included at the top of this file so as to aleart everyone to the sensitivity of this data.*

---------------------------------------------------------------------------

~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
**NOTE: This repository contains customer data an cannot be made public.**
~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=

---------------------------------------------------------------------------

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
* virtualenv: https://pypi.python.org/pypi/virtualenv#installation
* Pandoc: http://johnmacfarlane.net/pandoc/installing.html
* Graphviz: http://www.graphviz.org/Download.php
* P4Merge: http://www.perforce.com/product/components/perforce-visual-merge-and-diff-tools

_Tip_:  Modify your `.gitconfig` to add P4Merge to your Git configuration:

```
[diff]
    tool = p4merge_d
[difftool "p4merge_d"]
    cmd = \"C:/Program Files/Perforce/p4merge.exe\" "$(cygpath -wa $REMOTE)" "$(cygpath -wa $LOCAL)"
[difftool]
    prompt = false
[merge]
    tool = p4merge
[mergetool "p4merge"]
    cmd = \"C:/Program Files/Perforce/p4merge.exe\" \"$BASE\" \"$REMOTE\" \"$LOCAL\" \"$MERGED\"
[mergetool]
    prompt = false
```


Installation
------------
- [bootstrap.bat](http://arnie/packages/bootstrap/bootstrap.bat) will install Python and Windows-based dependencies. It will then download [bootstrap.py](http://arnie/packages/bootstrap/bootstrap.py) which
will install other dependencies through `pip`.
- Install Git for your environment.
- Clone the Git repo and edit the requirements.
- Install other 3rd party tools
- The `Makefile` will create a virtualenv and take care of all dependencies related to automatic checks.


Basic Usage
------------
Use the provided `Makefile` to generate files and check requirements validity.

The `Doorstop` tool is used to generate requirements in the `specs/` directory.

The following items will be created in the directories:

* env/ - a Python `virtualenv` to control the tool configuration for development
* docs/ - directory for generated document files
* xlsx/ - directory for temporary Excel files for editing
* zips/ - directory for *.zip generated from docs


Requirements Management
=======================

Specifications
----------------

Create the development environment:

```
$ make depends
```

Create Documents (see `Doorstop` for details):

```
$ source env/Scripts/activate
$ doorstop create -p [parent prefix] -d [padded digits] [prefix] specs/[folder]
$ [edit] specs/[folder]/.doorstop.yml // sep: '-'
$ [VCS commit]
$ deactivate
```

Edit Documents:

```
$ make excel-export
$ [edit Excel file] [save/close]
$ [VCS commit]
$ make excel-import
```

Validate Traceability:

```
$ make reqcheck
```

View Documentation:

```
$ make read
```

Release Specifications:

```
$ [edit] specs/__version__.py
$ [VCS add/commit]
$ make release
```


Feature Planning
----------------

Feature planning can be managed using the VCS (version control system, e.g. SVN, Git).

Changes affecting all current/future releases are edited in the `master` branch, then merged onto the `target` branch. Modifications of content specific to a targeted feature release are made only on the `target` branch.

The _merge_ feature within Git is optimal as it correctly remembers the order of changes made after `master` is merged onto `target` so that other changes going forward do not overwrite pervious modifications.

**!!!Important!!!** Never _merge_ `target` back onto `master` as this will essentially force `master` to mirror the `target`.

Requirements are added in their original form on `master`. If a feature is determined to be _not planned_ for `target`, it's `active` property is set to `FALSE` after is initially merge from `master`.
