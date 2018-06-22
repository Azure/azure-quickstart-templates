# Red Hat OpenShift Container Platform on Azure

## SSH Key Generation - Linux/CentOS/Fedora
1. Open the Terminal in the Application/Utilities folder.
![Terminal ScreenShot][terminal]
2. Enter the commands:
```bash
ssh-keygen -t rsa
```
3. At this point you will be prompted:

```bash
Generating public/private RSA key pair.
Enter file in which to save the key (/Users/test/.ssh/id_rsa):
Created directory '/Users/test/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/test/.ssh/id_rsa.
Your public key has been saved in /Users/test/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:2KeBdOEN/empJoqPYXuSMv5elJbS0KMwlcQBX4KuSPM test@host.com
The keys randomart image is:
+---[RSA 2048]----+
|  .==o. o.       |
|  .oo+ . +.      |
| .o o + o .. .   |
| o.o = O    o    |
|o.o o O S .. .   |
|o  E +   +  o    |
|    o.. .  .     |
|  o.o*. . o      |
| ..=*+o. o       |
+----[SHA256]-----+
```

Your public and private keys are now available in your home folder under the .ssh directory.


[terminal]:  https://github.com/openshift/openshift-ansible-contrib/raw/master/reference-architecture/azure-ansible/images/terminal.png
