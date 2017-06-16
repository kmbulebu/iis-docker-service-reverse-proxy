FROM microsoft/iis:latest

RUN powershell Invoke-WebRequest http://download.microsoft.com/download/E/9/8/E9849D6A-020E-47E4-9FD0-A023E99B54EB/requestRouter_amd64.msi -UseBasicParsing -OutFile C:/requestrouter.msi; \
  Start-Process msiexec -ArgumentList '/i C:\requestrouter.msi /qn' -Wait; rm C:\requestrouter.msi

RUN powershell Invoke-WebRequest http://download.microsoft.com/download/C/9/E/C9E8180D-4E51-40A6-A9BF-776990D8BCA9/rewrite_amd64.msi -UseBasicParsing -OutFile C:/rewrite.msi; \
  Start-Process msiexec -ArgumentList '/i C:\rewrite.msi /qn' -Wait; rm C:\rewrite.msi

ADD entrypoint.ps1 C:/entrypoint.ps1
ADD web.config C:/inetpub/wwwroot/web.config

EXPOSE 80/tcp 443/tcp

ENTRYPOINT ["powershell","-File","C:/entrypoint.ps1"]
