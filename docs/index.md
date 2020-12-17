# Protecting Crypto Currency

After making a small investment in some main stream crypto currencies like Bitcoin and etc, it became very clear that leaving the crypto currency in a crypto exchange wasn't best way to protect the crypto currency. After trying several different crypto wallets, I took a liking to the **Exodus** wallet (**Exodus.io**) and moved my crypto currency to it.

The downside to maintaining crypto currency in your own wallet is you now become **solely** responsible for maintaining and protecting the data. **Exodus** provides good documentation and functionality on how to keep your wallet data safe and I follow those instructions to the letter.  Since I'm responsible, I'm going to take some extra measures to ensure the safety and protection of the data plus add some functionality on top of what **Exodus** already provides.

I wanted to find another more mobilized and secure way to protect my crypto currency data rather than resorting to using a hardware wallet.

So I've put together several PowerShell cmdlets that provides me with a high degree of confidence that my **Exodus** wallet will always be available and never be lost or be comprised regardless of any circumstanses that might arise. In addition, the whole process is fully automated and simple enough for a casual Windows person to implement.

My goals are:

  1. To have the Exodus application and the wallet data available on any Windows 10 computer at anytime on the home network.

  2. To have a hardware wallet functionality without purchasing a hardware wallet. (a.k.a SW Hardware wallet)

  3. To have the Exodus application, wallet data, and integrated software restorable from offline media to any Windows 10 computer.

  4. To have the ability to have multiple wallets.

  5. The process needs to be easy enough implement that even a non-technical person can operate and implement the solution.

To achieve these goals other open sourced software needs to be utilized along with **Exodus**.

- **PasswordSafe** (Password Management)
- **VeraCrypt** (SW Hardware wallet)
- **Subversion** (SVN synchronization of wallets across home network)
- **TortoiseSVN** (SVN Client software )

PowerShell is used to stitch together Exodus and the other software to deliver a single soluiton for protecting my crypto currency.

What benefits does the other software provide?

- **VeraCrypt**
  - adds the ability to create encrypted containers that can be mounted as drive letters on Windows 10 and other operating systems too.
  - both the password data and the wallet data are maintained in separate encrypted containers and mounted as different drive letters.
  - A copy of the encrypted containers are maintained on removable media such as a USB or MircoSD drive.
  - The encrypted containers can be optionally removed from the local hard drive and only accessed if the USB or MicroSD is mounted.
  - Adds a second layer of encryption on top of the data that the applications have already encrypted.

- **PasswordSafe**
  - Extra long passwords are very difficult to crack using brute force methods, but also impossible to remember.
  - Provides the ability to use extra long passwords on wallets and a means to retreive those passwords.

- **Subversion**
  - Localized implementation only.
  - Provides for quick recovery of both the application and its data.
  - Provides the ability for other computers on the home network to quickly install the application and its data.

- **TortoiseSVN**
  - Provides Windows Explorer and command line interface to the Subversion server repository.

- **PowerShell**
  - The glue that allows all of these software components to work together to provide a solution to the problems at hand.
  ***

Anyone with enough compute resources and time can break any encryption scheme without knowing the password. History has proven this to be
true. So the best security is to keep the data offline which provides physical control of the data.

The **Start-Wallet** cmdlet in the **Moolah** module provides an automate process for controlling physical access to your crypto currency wallet data.