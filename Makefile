# $Id: Makefile 91 2010-11-24 12:44:17Z mitrandir $

MISC_CMD := --thread --vapidir vapi/

PKGS := gtk+-2.0 sqlite3 libcurl

ifdef FREMANTLE
	DEFS := $(DEFS) FREMANTLE
	MAEMO = 1
endif
ifdef DIABLO
	DEFS := $(DEFS) DIABLO
	MAEMO = 1
	MISC_CMD := $(MISC_CMD) --vapidir=vapi/diablo
endif

ifdef MAEMO
	DEFS := $(DEFS) MAEMO
	PKGS := $(PKGS) hildon-1 dbus-glib-1 libhildonmime hildon-gtk
endif

ifdef WINDOWS
	DEFS := $(DEFS) WINDOWS
	MISC_CMD := $(MISC_CMD) --Xcc=-mwindows --Xcc=-Isqlite --Xcc=-Lsqlite --Xcc=-lsqlite3 --Xcc=-lcurldll -v
endif

ifdef DEBUG
    MISC_CMD := $(MISC_CMD) -g
endif

ifdef GEN_C
    MISC_CMD := $(MISC_CMD) -C
endif

ifdef OPTIMIZE
    MISC_CMD := $(MISC_CMD) --Xcc=-O2
endif

SOURCES = \
    Main.vala               \
    Task.vala               \
    TaskTreeModel.vala      \
    TaskCellRenderer.vala   \
    TaskDialog.vala         \
    Command.vala            \
    CommandStack.vala       \
    Saver.vala              \
    Loader.vala             \
    GtkUtil.vala            \
    LoginDialog.vala        \
    Plan.vala               \
    Sync.vala               \
    PlanWidget.vala         \
    Config.vala             \
    Util.vala               \
    PlanSelectionWindow.vala\
    PlanSetListModel.vala


DEFS_CMD := $(addprefix -D , $(DEFS))
PKGS_CMD := $(addprefix --pkg ,$(PKGS))


all: planaris

ifdef WINDOWS
planaris: $(SOURCES) sqlite/libsqlite3.a
else
planaris: $(SOURCES)
endif
	valac $(MISC_CMD) $(PKGS_CMD) $(DEFS_CMD) --Xcc=-DGETTEXT_PACKAGE=\"planaris\" $(SOURCES) -o $@

ifdef WINDOWS
sqlite/libsqlite3.a: sqlite/sqlite3.c
	gcc -O2 -c sqlite/sqlite3.c -o sqlite/sqlite3.o
	ar r sqlite/libsqlite3.a sqlite/sqlite3.o
else
sqlite-win32:
	
endif

clean:
	rm -f planaris



install: planaris
	cp planaris $(DESTDIR)/usr/bin/
	cp locale/ru_RU/planaris.mo $(DESTDIR)/usr/share/locale/ru_RU/LC_MESSAGES/
ifdef MAEMO
	cp planaris.desktop $(DESTDIR)/usr/share/applications/hildon/
else
	cp planaris.desktop $(DESTDIR)/usr/share/applications/
endif
