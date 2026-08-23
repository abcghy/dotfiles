# bt-audio-healer

Keeps Bluetooth headphones from disappearing out of the audio output list.

## The bug it works around

Powering headphones off while audio is still streaming kills the A2DP transport
uncleanly:

```
spa.bluez5.sink.media: connection (.../sep3/fd0) terminated unexpectedly
pw.node: (bluez_output.<MAC>.1) running -> error (Received error event)
spa.bluez5: Failure in Bluetooth audio transport
```

WirePlumber leaves the node in `error` and tears the card down, but BlueZ still
reports the device as Connected. Powering the headphones back on reconnects
them, yet they never reappear as an output device. Doing a manual
disconnect/reconnect is the only cure.

Seen on PipeWire 1.6.8 / WirePlumber 0.5.15 / BlueZ 5.87 with a Sony WH-1000XM6.

## What the service does

Watches BlueZ over D-Bus (plus a 30s sweep as a safety net) and heals a device
that is **Connected**, advertises an **A2DP sink**, yet has **no
`bluez_card.<MAC>`** in PipeWire — by running a clean Disconnect/Connect cycle.

- A card switched to the `off` profile still exists, so a deliberate profile
  choice is never overridden.
- Retries 3x, then backs off 300s — a device that is simply still powered off
  fails `Connect()` harmlessly and does not get hammered.
- Not tied to one device: any A2DP sink qualifies.

## This is a backup

These files are a copy, not the live install — nothing here is wired into
`install.conf.yaml`, and `./install` does not touch them. The running copies are
`~/.local/bin/bt-audio-healer` and
`~/.config/systemd/user/bt-audio-healer.service`; edits here do not reach them.

To restore on a fresh machine (needs `python3` + `python-gobject`):

```sh
install -Dm755 bt-audio-healer ~/.local/bin/bt-audio-healer
install -Dm644 bt-audio-healer.service ~/.config/systemd/user/bt-audio-healer.service
systemctl --user daemon-reload
systemctl --user enable --now bt-audio-healer.service
```

Note the unit has to be a real copy: `systemctl enable` refuses a unit file that
is a symlink pointing outside its search directories (`UnitFileState=bad`).

## Checking on it

```sh
systemctl --user status bt-audio-healer
journalctl --user -u bt-audio-healer -f
```
