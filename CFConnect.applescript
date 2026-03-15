-- This script gives a menu of machines to remote to using cloudflared and Mac screenshare. 

-- Add new hosts to targetList. Each item is a record. Leave the "other" record last.
-- name = friendlyname to be used in Menu
-- port = localport to be used. Unique port for password saving w/ screenshare.
-- hostname = full cloudflare hostname.  
set targetList to ¬
	{{|name|:"Machine01", |port|:5911, hostname:"machine01-vnc.yourdomain.com"}, ¬
		{|name|:"Machine02", |port|:5912, hostname:"machine02-vnc.yourdomain.com"}, ¬
		{|name|:"Machine03", |port|:5913, hostname:"machine03-vnc.yourdomain.com"}, ¬
		{|name|:"Other", |port|:5999, hostname:""}}

-- grabs friendly names of targets for the Menu		
set targetMenu to {}
repeat with target in targetList
	set targetMenu to targetMenu & |name| of target
end repeat

-- Gives users a menu option of machines to connect
set targetChoice to choose from list targetMenu with prompt "Select which machine to connect to:" default items {item 1 of targetMenu}

-- if cancel button hit then exit
if targetChoice is false then
	error number -128
end if

-- if other selected. Gives option to use hostname not in Menu
if (targetChoice as string) = "Other" then
	set textDialog to display dialog "Enter full cloudflare hostname of machine" default answer "" with icon note buttons {"Cancel", "Continue"} default button "Continue"
	set buttonResult to button returned of textDialog
	set otherHostname to text returned of the textDialog
	if buttonResult is "Cancel" then
		error number -128
	end if
end if
	
-- loops through targetList for the menu option selected. Record properties are saved for use
-- also adds custom hostname to the the "other" record if other was selected.
repeat with target in targetList
	if (targetChoice as string) = |name| of target then
		set targetProperties to target
		if (targetChoice as string) = "Other" then
			set hostname of targetProperties to otherHostname
		end if
		exit repeat
	end if
end repeat

-- variables set by record properties. To be used in cloudflare and screenshare commands
set hostname to hostname of targetProperties
set portNum to |port| of targetProperties
set cfArg to " --url localhost:" & portNum & " &> /dev/null & echo $!"

-- Detect cloudflared path. Checks PATH first, then common install locations.
-- Homebrew on Apple Silicon: /opt/homebrew/bin | Homebrew on Intel: /usr/local/bin | Manual install: /opt/cloudflared
set cfPath to do shell script "command -v cloudflared 2>/dev/null || ls /opt/homebrew/bin/cloudflared /usr/local/bin/cloudflared /opt/cloudflared/cloudflared 2>/dev/null | head -1 || echo ''"
if cfPath is "" then
	display dialog "cloudflared not found. Please install it and try again." buttons {"OK"} default button "OK" with icon stop
	error number -128
end if

try
	do shell script cfPath & " access login " & hostname
on error errMsg
	display dialog "Cloudflare login failed: " & errMsg buttons {"OK"} default button "OK" with icon stop
	error number -128
end try

try
	do shell script cfPath & " access tcp --hostname " & hostname & cfArg
	--pid saved to close cloudflared process when finished
	set pid to the result
on error errMsg
	display dialog "Failed to open cloudflared tunnel: " & errMsg buttons {"OK"} default button "OK" with icon stop
	error number -128
end try

-- Note: open --wait-apps will NOT block if Screen Sharing is already open from a prior session.
-- Close any existing Screen Sharing window first to ensure the tunnel is cleaned up on exit.
do shell script "open --wait-apps vnc://localhost:" & portNum
-- kill cloudflared pid
do shell script "kill " & pid