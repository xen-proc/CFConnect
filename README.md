# CFConnect

 AppleScript to open Cloudflare Access tunnels and launch MacOS Screen Sharing to remote machines. Provides a menu to select machines. Created to give a convenient method for users to screenshare into machines. Edit the list of machines in the script, compile, and share.

## Prerequisites

- [cloudflared](https://github.com/cloudflare/cloudflared) installed (use `installcf.sh` or Homebrew)
- Cloudflare Access configured with a TCP application for each host
- Screen Sharing enabled on remote machines

## Setup

**1. Install cloudflared**

Run `installcf.sh` to install or update cloudflared to `/opt/cloudflared/`. On first run it installs; on subsequent runs it updates.

> The app detects cloudflared automatically across common install paths (`/opt/cloudflared`, `/opt/homebrew/bin`, `/usr/local/bin`).

**2. Edit `CFConnect.applescript`**

Update `targetList` with your own hosts:

```applescript
set targetList to ¬
    {{|name|:"Machine01", |port|:5911, hostname:"machine01-vnc.yourdomain.com"}, ¬
     {|name|:"Other",     |port|:5999, hostname:""}}
```

- `name` — label shown in the menu
- `hostname` — your Cloudflare Access TCP hostname
- `port` — a unique local port per host (see note below)

> **Why unique ports?** macOS Keychain saves VNC passwords per port. Assigning a unique port to each host ensures credentials are saved and recalled correctly.

**3. Package as an app**

```bash
chmod +x createapp.sh
./createapp.sh
```

This compiles `CFConnect.applescript` into `/Applications/CFConnect.app` using `osacompile`.

## Usage

Launch `/Applications/CFConnect.app`. Select a machine from the menu. The app will authenticate via Cloudflare, open the tunnel, and launch Screen Sharing. The tunnel is closed automatically when Screen Sharing is quit.

> If Screen Sharing is already open from a previous session, close it before connecting to ensure the tunnel closes properly on exit.
