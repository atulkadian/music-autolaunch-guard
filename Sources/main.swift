import AppKit

private let blockedBundleIDs: Set<String> = ["com.apple.Music", "com.apple.iTunes"]
private let enabledKey = "blockingEnabled"

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let defaults = UserDefaults.standard
    private var statusItem: NSStatusItem!
    private let toggleItem = NSMenuItem(title: "Block Apple Music", action: #selector(toggle), keyEquivalent: "")

    private var isEnabled: Bool {
        get { defaults.object(forKey: enabledKey) as? Bool ?? true }
        set {
            defaults.set(newValue, forKey: enabledKey)
            refreshUI()
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        toggleItem.target = self
        let menu = NSMenu()
        menu.addItem(toggleItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Music Autolaunch Guard", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        refreshUI()

        // willLaunch fires before Music draws a window; didLaunch catches anything it misses.
        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.willLaunchApplicationNotification, NSWorkspace.didLaunchApplicationNotification] {
            center.addObserver(self, selector: #selector(appLaunched(_:)), name: name, object: nil)
        }
        NSLog("started, blocking %@", isEnabled ? "on" : "off")
    }

    @objc private func appLaunched(_ note: Notification) {
        guard isEnabled,
              let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let id = app.bundleIdentifier, blockedBundleIDs.contains(id),
              !app.isTerminated
        else { return }
        app.forceTerminate()
        NSLog("blocked %@ (pid %d)", id, app.processIdentifier)
    }

    @objc private func toggle() {
        isEnabled.toggle()
        NSLog("blocking %@", isEnabled ? "on" : "off")
    }

    private func refreshUI() {
        toggleItem.state = isEnabled ? .on : .off
        let symbol = isEnabled ? "music.note.slash" : "music.note"
        statusItem.button?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "Music Autolaunch Guard")
    }
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}
