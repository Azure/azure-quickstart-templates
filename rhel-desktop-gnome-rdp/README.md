# Gnome Desktop on RHEL VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F251744647%2Fazure-quickstart-templates%2Fmaster%2Frhel-desktop-gnome-rdp%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

This template uses the Azure Linux CustomScript extension to deploy Gnome Desktop on the VM. It creates an RHEL VM, does a silent install of gnome desktop and xrdp, allows you to connect it with Remote Desktop from a Windows machine.



Please kindly note that if you use windows remote desktop client to connect to xrdp and receive an error message similar to "…only supporting 8,15,16,24 bpp rdp connections." One possibility is that your remote desktop client is set to use Highest Quality (32) Colors.  You have to lower this setting. Follow this: "Remote Desktop Connection" -- "Show options" -- "Display" -- "Colors" -- choose the color. 