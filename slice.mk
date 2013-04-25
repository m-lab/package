SLICENAME?=notset
ifeq ($(SLICENAME),notset)
    $(error 'SLICENAME' is a required variable. Please set it to the name of your slice.)
endif

# NOTE: use sensible defaults in case they're not already set.
RPMBUILD?=../build/slicebase-$(shell uname -i)
TMPBUILD?=../build/tmp
SPECFILE?=$(TMPBUILD)/$(SLICENAME)-slicebase.spec
BUILD_DIR?=/home/$(SLICENAME)

pkgname=$(shell rpm -q --qf "%{NAME}\n" --specfile $(SPECFILE) | head -1)
version=$(shell rpm -q --qf "%{VERSION}\n" --specfile $(SPECFILE) | head -1)

PKGNAME=$(pkgname)-$(version)
TARNAME=$(PKGNAME).tar
BZ2NAME=$(PKGNAME).tar.bz2
RPMNAME=$(PKGNAME).rpm

PKGDIR=$(TMPBUILD)/$(PKGNAME)
TARFILE=$(TMPBUILD)/$(TARNAME)
BZ2FILE=$(TMPBUILD)/$(BZ2NAME)
RPMFILE=$(RPMBUILD)/$(RPMNAME)

all: $(PKGDIR) $(TARFILE) $(RPMFILE)

RPMDIRDEFS=--define "_sourcedir $(TMPBUILD)" --define "_builddir $(TMPBUILD)" 
RPMDIRDEFS+= --define "_srcrpmdir $(TMPBUILD)" --define "_rpmdir $(RPMBUILD)"

$(PKGDIR):
	mkdir -p $(PKGDIR)

# NOTE: collect all files in the current directory
SLICEFILES=$(shell find $(BUILD_DIR) -type f -a -print | grep -v .tar.bz2 )

# NOTE: this make the tar file dependent on all files 
$(TARFILE): $(PKGDIR) $(FILES)
	# NOTE: copy slicebase files into pkg dir
	rsync -ar $(SOURCE_DIR)/package/slicebase $(PKGDIR)/
	rsync -ar --exclude ".svn" $(BUILD_DIR)/ $(PKGDIR)/
	tar --exclude ".svn" --exclude ".*.swp" --exclude "*.tar" \
		-cvf $(TARFILE) -C $(TMPBUILD) $(PKGNAME)

$(BZ2FILE): $(TARFILE)
	bzip2 -f $(TARFILE)

$(RPMFILE): $(BZ2FILE)
	rpmbuild $(RPMDIRDEFS) -bb $(SPECFILE)

clean:
	rm -rf $(PKGDIR)
	rm -f $(TARFILE)
	rm -f $(BZ2FILE)
