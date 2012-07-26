##################################################################################
# Makefile - Configuration file for GNU make (http://www.gnu.org/software/make/)
# Creation : 26 Jul 2012
# Time-stamp: <Thu 2012-07-26 11:10 svarrette>
#
# Copyright (c) 2012 Sebastien Varrette <Sebastien.Varrette@uni.lu>
#               http://varrette.gforge.uni.lu
# $Id$ 
#
# Available Commands  
# ------------------
# make           : Compile files, binaries are generated in the current directory  
# make force     : Force the complete re-compilation, even if not needed 
# make clean     : Remove backup files (*~) and other generated files        
#
############################## Variables Declarations ############################
SHELL = /bin/bash

# Directory hosting the LaTeX sources
LATEX_SRCDIR = src_LaTeX
URT_GUIDE    = $(LATEX_SRCDIR)/urt_setup.pdf

# Gitflow stuff for release management
GRB             = $(shell which grb)
GITFLOW         = $(shell which git-flow)
LAST_TAG_COMMIT = $(shell git rev-list --tags --max-count=1)
LAST_TAG        = $(shell git describe --tags $(LAST_TAG_COMMIT) )
TAG_PREFIX      = "urbanterror_guide-v"

VERSION  = $(shell head VERSION)
# OR try to guess directly from the last git tag
#VERSION    = $(shell  git describe --tags $(LAST_TAG_COMMIT) | sed "s/^$(TAG_PREFIX)//")
MAJOR    = $(shell echo $(VERSION) | sed "s/^\([0-9]*\).*/\1/")
MINOR    = $(shell echo $(VERSION) | sed "s/[0-9]*\.\([0-9]*\).*/\1/")
PATCH    = $(shell echo $(VERSION) | sed "s/[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/")
# total number of commits 		
BUILD    = $(shell git log --oneline | wc -l | sed -e "s/[ \t]*//g")
NEXT_MAJOR_VERSION = $(shell expr $(MAJOR) + 1).0.0-b$(BUILD)
NEXT_MINOR_VERSION = $(MAJOR).$(shell expr $(MINOR) + 1).0-b$(BUILD)
NEXT_PATCH_VERSION = $(MAJOR).$(MINOR).$(shell expr $(PATCH) + 1)-b$(BUILD)

.PHONY: all release setup start_bump_major start_bump_minor start_bump_patch versioninfo  
############################### Now starting rules ################################
all: 
	@$(MAKE) -C $(LATEX_SRCDIR)/
	@echo ""
	@echo "=> the Urbanterror guide has been generated in $(LATEX_SRCDIR)/"
	@[ -f "$(URT_GUIDE)" ] && ln -s $(URT_GUIDE) .
	@echo "A symbolic link has been created in this directory"

ifeq ($(GRB),)
setup: 
	@echo "Unable to find the 'grb' binary. Install it to setup your git repository."
	@echo "See https://github.com/webmat/git_remote_branch/ for more details"
else 
setup:
	grb grab production
	git config gitflow.branch.master     production
	git config gitflow.branch.develop    master
	git config gitflow.prefix.feature    feature/
	git config gitflow.prefix.release    release/
	git config gitflow.prefix.hotfix     hotfix/
	git config gitflow.prefix.support    support/
	git config gitflow.prefix.versiontag $(TAG_PREFIX)
endif

versioninfo:
	@echo "Current version: $(VERSION)"
	@echo "Last tag: $(LAST_TAG)"
	@echo "$(shell git rev-list $(LAST_TAG).. --count) commit(s) since last tag"
	@echo "Build: $(BUILD) (total number of commits)"
	@echo "next major version: $(NEXT_MAJOR_VERSION)"
	@echo "next minor version: $(NEXT_MINOR_VERSION)"
	@echo "next patch version: $(NEXT_PATCH_VERSION)"

# Git flow management - this should be factorized 
ifeq ($(GITFLOW),)
start_bump_patch start_bump_minor start_bump_major release: 
	@echo "Unable to find git-flow on your system. "
	@echo "See https://github.com/nvie/gitflow for installation details"
else
start_bump_patch:
	@echo "Start the patch release of the repository from $(VERSION) to $(NEXT_PATCH_VERSION)"
	git pull origin
	git flow release start $(NEXT_PATCH_VERSION)
	@echo $(NEXT_PATCH_VERSION) > VERSION
	git commit -s -m "Patch bump to version $(NEXT_PATCH_VERSION)" VERSION
	@echo "=> remember to update the version number in $(MAIN_TEX)"
	@echo "=> run 'make release' once you finished the bump"

start_bump_minor:
	@echo "Start the minor release of the repository from $(VERSION) to $(NEXT_MINOR_VERSION)"
	git pull origin
	git flow release start $(NEXT_MINOR_VERSION)
	@echo $(NEXT_MINOR_VERSION) > VERSION
	git commit -s -m "Minor bump to version $(NEXT_MINOR_VERSION)" VERSION
	@echo "=> remember to update the version number in $(MAIN_TEX)"
	@echo "=> run 'make release' once you finished the bump"

start_bump_major:
	@echo "Start the major release of the repository from $(VERSION) to $(NEXT_MAJOR_VERSION)"
	git pull origin
	git flow release start $(NEXT_MAJOR_VERSION)
	@echo $(NEXT_MAJOR_VERSION) > VERSION
	git commit -s -m "Major bump to version $(NEXT_MAJOR_VERSION)" VERSION
	@echo "=> remember to update the version number in $(MAIN_TEX)"
	@echo "=> run 'make release' once you finished the bump"


release: $(TARGET_PDF)
	@cp $(TARGET_PDF) $(TARGET_PDF:%.pdf=%-v$(VERSION).pdf)
	git flow release finish -s $(VERSION)
	git push origin --tags
endif


%:
	$(MAKE) -C $(LATEX_SRCDIR)/ $@


