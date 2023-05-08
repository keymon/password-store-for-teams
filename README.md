Password store template for teams
=================================

This repository contains a base template for a
[password store repository](http://passwordstore.org/) to be used by teams.

It contains:
 * A README.md to adapt to your team
 * A script to set up a unique alias based on the directory name.
 * A Makefile with some common tools

This is based on some original work from me and some contributions from
my [colleagues in GDS](https://github.com/alphagov) :)

How to use it?
--------------

Assuming you want to call your pass alias `team-pass`, but any other alias
can be used.

 1. Clone this repo in a directory like ~/.team-pass
 2. Adapt the README.md to remove these first instructions. Specially
    change the strings:
    * `<TEAM-GIT-REPO-URL>`
    * `team-pass`
 3. Install pass as described in the instructions below
 4. Init your pass repo:

```
    cd ~/.team-pass
    pass init GPGID GPGID GPGID GPGID ... # All your teams ids
```
 5. Share it with your team :)


Team shared credential store
============================

This is a Git repository that contains a Database of passwords shared in the team.

**IMPORTANT**: This repository **is a database** managed by external
opensource software called *pass* (http://passwordstore.org/),
that you must install in your computer (instructions below).

How to use it?
==============

First you need access to the git repository that contains the database. We
will store this in the internal GitHub repository.

You also need a valid gpg key with all the keys encrypted.

Installing pass using packages
------------------------------

Some quick command to install it using native packages in most common
distributions and OS:

 * MacOSX: `brew install pass gnupg`
 * Debian/Ubuntu/Mint: `sudo apt-get install pass`
 * Redhat/Centos/Fedora: `sudo yum install pass`

You will need version 1.5 or later. Default Ubuntu 14.04 version is 1.4.2. You
can get latest version from [github](https://github.com/zx2c4/password-store/releases).
Unpack and install using:

    sudo make install

Internet helps
--------------

Additionally, if this doesn't work, you can find guides on the internet:

 * http://zx2c4.com/projects/password-store/#download
 * http://www.stackednotion.com/blog/2012/09/10/setting-up-pass-on-os-x/

Cloning the repo and setting paths
----------------------------------

I recommend you clone this in a different directory than the default pass DB
so it does not conflict with your own private pass DB. To do that, you should
clone the pass repo in a alternate location and create an alias to use pass
with the command `team-pass` by following these instructions:

    git clone <TEAM-REPO-URL> ~/.team-pass

If this doesn't work for you, try cloning using:

    git clone <TEAM-REPO-URL> ~/.team-pass

If you use Bash (probably), add this to your `~/.bashrc`:

    # Load the custom .*-pass I have
    for i in ~/.*-pass; do
      [ -e $i/.load.bash ] && . $i/.load.bash
    done

Now just reload your bash:

    exec bash -l
    team-pass

Check if you have any problem with this script, or if you are using other shell.

Finally, import and sign the keys (see untrusted key issue below for full explanation):

    make import-and-sign

Updating repo, Adding passwords, etc.
-------------------------------------

I encourage you to read the man page, `man pass` or http://git.zx2c4.com/password-store/about/

There's also inline help: `team-pass --help`

1. Get last version of the repo:

        team-pass git pull --rebase
        team-pass git push

2. Generate a password and push branch for a pull request:

        team-pass generate -n os/dev/test 16  # Will generate a password without symbols of 16 characters
        team-pass git push

3. Delete a password and push branch for a pull request:

        team-pass delete os/dev/test
        team-pass git push

Adding and removing recipients
------------------------------

The current list of recipients can be listed with:

    make list-keys

New recipients will need to send their GPG key ID to an existing recipient.
This can be found with:

    gpg -K

To make the key available to others you should add it to a keyserver.

    gpg --send-keys <gpg key ID>

An existing recipient should add this to the file `.gpg-id`. Similarly, old
recipients that you no longer wish to have access, can be removed from this
file. However they will still have access to old versions of the password
store so you should rotate all of the contained passwords at the same time.

To re-encrypt the passwords against the new list of recipients:

    team-pass git checkout -b change_recipients
    team-pass init $(cat .gpg-id)

For jenkins or any other subdirectory:

    team-pass init -p jenkins $(cat jenkins/.gpg-id)

Then:

    team-pass git push origin change_recipients
    team-pass git checkout master

You should then create a pull request from that pushed branch.

Known issues
============

untrusted key
-------------

If you get an error `gpg: BB78B8A9: There is no assurance this key belongs to the named user`:

```
gpg: 1C818280: There is no assurance this key belongs to the named user
gpg: /var/folders/y8/7v28hjzx673cr9j19_16xnv40000gn/T/pass.XXXXXXXXXXXXX.X5vBmbwl/pass.XXXXXXXXXXXXX.EGvtwyJ9: encryption failed: Unusable public key
GPG encryption failed. Retrying.
```

Run the make target which will import and sign all of the teams keys:

    make import-and-sign

It will prompt you for each change and will not push the signatures to a
remote keyserver. This is marginally better than needing to "ultimately"
trust all of the other recipients, because they could have an effect on what
other keys you implicitly trust based on their signatures.

shell initialization
--------------------

The script `.team-pass/.load.bash` contains generic code to define the aliases and shell completion.

You might need to adapt the script to work with other shells (csh, fish, etc).

There are completion definitions in the original pass source code for fancy shells.


