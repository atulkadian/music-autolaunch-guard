LABEL  := local.music-autolaunch-guard
PREFIX ?= $(HOME)/.local/bin
BIN    := $(PREFIX)/music-autolaunch-guard
PLIST  := $(HOME)/Library/LaunchAgents/$(LABEL).plist
LOG    := $(HOME)/Library/Logs/music-autolaunch-guard.log
DOMAIN := gui/$(shell id -u)

.PHONY: build run install uninstall restart log

build: .build/music-autolaunch-guard

.build/music-autolaunch-guard: Sources/main.swift
	mkdir -p .build
	swiftc -O -o $@ $<

run: build
	.build/music-autolaunch-guard

install: build
	mkdir -p $(PREFIX) $(dir $(PLIST))
	install -m 755 .build/music-autolaunch-guard $(BIN)
	sed -e "s|@BIN@|$(BIN)|" -e "s|@LOG@|$(LOG)|" launchd/$(LABEL).plist > $(PLIST)
	@$(MAKE) --no-print-directory stop
	launchctl bootstrap $(DOMAIN) $(PLIST)
	@echo "Music Autolaunch Guard installed and running (look for the note icon in the menu bar)"

uninstall: stop
	rm -f $(PLIST) $(BIN)
	@echo "Music Autolaunch Guard removed"

restart:
	launchctl kickstart -k $(DOMAIN)/$(LABEL)

log:
	tail -f $(LOG)

# bootout returns before the job is gone; bootstrapping too early fails with "Input/output error".
.PHONY: stop
stop:
	@launchctl bootout $(DOMAIN)/$(LABEL) 2>/dev/null || true
	@while launchctl print $(DOMAIN)/$(LABEL) >/dev/null 2>&1; do sleep 0.2; done
