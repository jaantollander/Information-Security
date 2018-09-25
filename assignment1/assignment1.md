# Information Security - Assignment 1
## Part A: Setting up SSH authentication
Log in

SERVER:

```
ssh cloud-user@infosec1.vikaa.fi -p 33036

```

Change password
```
passwd
knEeGPyr
12345678
```

LOCAL MACHINE:

Create an `ed25519` key pair for yourself in SSH.
```
ssh-keygen -t ed25519
```

Copy the ssh key over to the server
```
ssh-copy-id -i ~/.ssh/id_ed25519.pub cloud-user@infosec1.vikaa.fi -p 33036
```


## Part B: File access control Linux

- https://www.linode.com/docs/tools-reference/linux-users-and-groups/

```
sudo adduser alice
sudo adduser bob
sudo adduser carol
sudo addgroup project2018
sudo adduser alice project2018
sudo adduser bob project2018
```

```
mv project/ /home/alice/
chown -R alice:project2018 project/
```

```
sudo chmod -R 775 project/
sudo chmod -R 660 project/code/
sudo chmod 770 project/code/
sudo chmod 775 project/poc
sudo chmod 700 project/confidential/
sudo chmod 664 project/product10.pdf
```
