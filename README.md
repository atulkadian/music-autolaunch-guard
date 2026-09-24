# music-autolaunch-guard

Stops Apple Music from opening when Bluetooth earphones connect or a media key gets pressed.

macOS routes Play/Pause to `rcd` (the Remote Control Daemon). When no other app owns "Now Playing", `rcd` launches Music. Disabling `rcd` would fix that but breaks media keys for every app, Spotify and browsers included. music-autolaunch-guard leaves `rcd` running and kills Music as soon as it launches.

It runs as a menu bar icon. Click it and untick **Block Apple Music** when you want to open Music yourself.

## Install

Needs the Xcode Command Line Tools (`xcode-select --install`).

```bash
make install
```

This builds the binary, copies it to `~/.local/bin/music-autolaunch-guard`, and loads a LaunchAgent (`~/Library/LaunchAgents/local.music-autolaunch-guard.plist`) so it starts at login.

## Commands

| Command          | What it does                                   |
| ---------------- | ---------------------------------------------- |
| `make run`       | Build and run in the foreground, for testing   |
| `make restart`   | Restart the installed agent                    |
| `make log`       | Follow `~/Library/Logs/music-autolaunch-guard.log` |
| `make uninstall` | Stop the agent and remove the binary and plist |

"Quit Music Autolaunch Guard" in the menu stops it until your next login. A crash restarts it.

## License

MIT. See [LICENSE](LICENSE).
