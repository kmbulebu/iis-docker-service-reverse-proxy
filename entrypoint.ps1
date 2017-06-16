Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Name 'enabled' -Filter 'system.webServer/proxy' -Value 'True'
# Uncomment to enable slightly more detailed error messages to HTTP clients.
# Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Name 'errorMode' -Filter 'system.webServer/httpErrors' -Value 'Detailed'

Stop-Website -Name 'Default Web Site'
Start-Website -Name 'Default Web Site'

Start-Process C:\ServiceMonitor.exe -ArgumentList "w3svc" -Wait
