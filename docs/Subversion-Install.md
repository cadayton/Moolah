# Subversion Installation

The Subversion server/client can be downloaded from [Download Subversion](https://www.wandisco.com/subversion/download).

**Subversion** (also commonly called **SVN**) is version control software used to maintain current and historical versions of files such as source code, web pages, and documentation.
SVN is a client/server application and as such there is both client software and server software that needs to be installed and configured.  GitHub is an example of another version control software that is very popular these days.  I use both. I've been using SVN for over 17 years for my private stuff and within the last year start using GitHub for my public stuff.

I'm not going to provide you with guidance on how to install and configure **SVN** for serveral reasons.  One it breaks the rule of keeping your crypto data offline so that you have physical control of your data. And the second reason is that it is fairly complicated for a novice person to set up and understand. There are plenty installation guides available on the internet that provide instructions on installing **SVN**.

The benefit for me in using **SVN** in combination with my crypto currency data are:

1. Easily retreat to prior versions of either the Exodus application or the wallet data.

2. Easily synchronize data between multiple computers on my home network.

If you decide to install and use **SVN**, the **Moolah** cmdlets will support synchronizing your data. It does this by detecting the present of the folder, *.svn*.  If the folder is present, the **Moolah** cmdlet will invoke the TortoriseSVN client to perform the commit operation.

## TortoiseSVN Installation

TortoiseSVN can be downloaded from [Download TortoiseSVN](https://tortoisesvn.net/downloads.html)

TortoiseSVN is **SVN** client plugin for Windows Explorer.

I find it easier to use than the standard **SVN** client command line interface.

If your planning on using **SVN**, then add the **installation path to the system path environmental variable**.  The **Moolah** cmdlets make use of the TortoiseSVN command line interface.
