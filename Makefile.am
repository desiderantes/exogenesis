## Process this file with automake to produce Makefile.in
## Created by Anjuta

SUBDIRS = src 

exogenesisdocdir = ${prefix}/doc/exogenesis
exogenesisdoc_DATA = \
	README\
	COPYING\
	AUTHORS\
	ChangeLog\
	INSTALL\
	NEWS


EXTRA_DIST = $(exogenesisdoc_DATA)


# Remove doc directory on uninstall
uninstall-local:
	-rm -r $(exogenesisdocdir)
