# VeraCrypt Installation

VeraCrypt can be downloaded from [Download VeraCrypt](https://www.veracrypt.fr/en/Downloads.html)

VeraCrypt is a free open source disk encryption software for Windows, Mac OSX and Linux. We will be creating two virtual encrypted disks within a file and mounting them as drive letter A and drive letter B.

**Drive A** will contain sensitive data that should always be encrypted like the PasswordSafe DB and anyother data of your choosing.

**Drive B** will contain the Exodus wallet directory.

Just following the default installation process.  **The installed path must be added to system path variable**.  Google it if you don't know how to do this.  Actually, use [StartPage](https://startpage.com) rather that Google for your internet searching. Google tracks all your activities.

Once the software is installed create serveral virtual disks for practices and mount them as drive letters on your system. For our purposes, I recommend formating the drive with a 'exFat' partition.  The 'exFat' filesystem can be used by many different operating systems, so it can be mounted on any system supported by VeraCrypt.