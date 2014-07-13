## Process this file with automake to produce Makefile.in

## Created by Anjuta


uidir = $(datadir)/exogenesis/ui
ui_DATA = exogenesis1.glade


AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(EXOGENESIS_CFLAGS)

AM_CFLAGS =\
	 -Wall\
	 -g

bin_PROGRAMS = exogenesis

exogenesis_SOURCES = \
	config.vapi cellrendererbutton.vala exoFComplete.vala exoFConfirm.vala exoFCreatePartition.vala exoFExistingUsers.vala exoFHDConfig.vala exoFInstall.vala exoFLocale.vala exoFPartitioner.vala exoFTimeZone.vala exoFUserConfig.vala exoFWelcome.vala exogeneralfuncs.vala exoHardDiskMgr.vala exoInstallData.vala exoLanguageMgr.vala exoPreviousOS.vala exoTZControl.vala exoxml.vala FexoMainWin.vala FTimeAdjustMan.vala main.vala segmentedbar.vala exoHDBasic.vala exoFHDconfigAdvanced.vala

exogenesis_VALAFLAGS =  \
	--pkg gtk+-3.0 --pkg gdk-3.0 --pkg gdu --pkg gee-0.8 --pkg liboobs-1 --pkg libxml-2.0 --pkg pango --pkg pangocairo --pkg posix --pkg gconf-2.0 --pkg gstreamer-0.10 --pkg gstreamer-interfaces-0.10 --pkg gdk-x11-3.0

exogenesis_LDFLAGS = \
	-Wl,--export-dynamic

exogenesis_LDADD = $(EXOGENESIS_LIBS)


EXTRA_DIST = $(ui_DATA)

# Remove ui directory on uninstall
uninstall-local:
	-rm -r $(uidir)
	-rm -r $(datadir)/exogenesis
