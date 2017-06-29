Start-Website -Name 'Default Web Site'

Start-Process C:\ServiceMonitor.exe -ArgumentList "w3svc" -Wait
