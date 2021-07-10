# Romanesco Seed

Romanesco is a collection of patterns and tools for creating websites in MODX.

Romanesco Seed is the starting point for installing and configuring a Romanesco project.

> **TL;DR**
>
> Just want the magic commands?
>
> - `git clone https://github.com/hugopeek/romanesco-seed`
> - `cd romanesco-seed`
> - `cp config.example config.sh`
> - `nano config.sh` (adjust variables for your environment)
> - `./romanesco plant gitify`
> - `./romanesco plant seed for project 'PROJECT NAME' in database -n DB_NAME -u DB_USER -p DB_PASS`
>
> But please, continue reading so you know what's going on. Romanesco works better if you're patient!

## Introduction

Romanesco is not exactly an add-on or standalone package, but more of an ecosystem from which beautiful and useful websites can emerge. Like flowers and vegetables growing in a garden.

A thriving garden always starts with good soil. For growing a Romanesco, the soil is a mix of [MODX][1], [ContentBlocks][2], a few other extras, a [pattern library][3], a [frontend framework][4] with [custom theme][5] and some JavaScript thingies. And like real soil, you can't just throw all these components together and expect things to grow. You need to carefully build it up.

After years of composting, cover cropping, hedge rowing, managed grazing, crop rotating and rewilding, [the soil for Romanesco][6] has become a complex compound of components and nutrient flows. Technically speaking: a lot of moving parts. To manually tie these parts together for every new install would be madness, so that's why this installer exists.

Romanesco Seed roughly takes care of the following steps:

- Prepare your environment for a new installation
    - Create a local Linux user
    - Configure Nginx and php-fpm
    - Generate SSL certificate
- Install server dependencies if needed
    - Gitify, for building and extracting data as flat files
    - Node, for running frontend and performance related tasks
- Set up Romanesco
    - Clone required repositories
    - Create database and user
    - Install MODX + packages
    - Build [Romanesco Soil][6] base installation
    - Build frontend assets with custom colors and logo (optional)

The preparation steps are optional and require root access on your server. It messes about with your server setup, with no guarantee that things will actually work. So needless to say: **proceed with caution** if you decide to run these steps. Try to check what they do first and make sure you have good backups.

If you don't want to fool around with the nuclear launch codes, or if you don't have root access, then not to worry. As long as you know how to tell your webserver about our new project and create an empty database, you should be OK. After that, you can plant Romanesco without any additional permissions.

## Prerequisites

Before we start, there are a few things that your environment requires:

- Any Linux distribution with the following tools:
    - rsync
    - sed
    - bash
    - service
- Nginx (if you want to run the preparation tasks) or Apache
- PHP 7.3 or higher
- MariaDB or MySQL
- Git
- [Composer](https://getcomposer.org/download/) (optional; will be installed locally if not found)
- [Certbot](https://certbot.eff.org/instructions) (optional, if you want use SSL)

### PHP exec function

Some Romanesco features use the exec function of PHP. This is disabled on a lot of shared web hosts (for good reasons). Some optional frontend and performance tasks won't run as a result, but the core functionality of Romanesco should still be OK.

If you're on a tightly sealed VPN (or your local computer), then you might want to enable the exec function in your php-fpm config. Comment out the following lines under /etc/php/7.X/fpm/pool.d/www.conf (or your custom pool):

```
;php_admin_value[disable_functions] = exec,passthru,shell_exec,system  
;php_admin_flag[allow_url_fopen] = off
```

### ModMore API key

There are 2 paid extras included in Romanesco: [ContentBlocks][2] and [Redactor][7], both developed by ModMore. You can try if for [free during development][8], but you still need an API key for that.

Go to modmore.com to create an account, log in and create the API key. Keep the window open, you'll need these credentials in the next step.

![[Pasted image 20210707225100.png]]

## Environment variables

If your environment fits the bill, then it's time to configure Romanesco Seed. There are a few paths and variables unique to your setup that it should know about.

To do this, copy the included sample config:

```shell
cp config.example config.sh
```

Open it with your editor of choice and configure all necessary options. The descriptions above the variables should be pretty self-explanatory. Don't forget to add the ModMore API key from the previous step.

## Database

Your project needs a MySQL database, which can be an existing one (as long as it's empty) or a new one created by the installer.

Credentials for an existing database can be added by appending them to the install command:

```shell
./romanesco plant seed for project X in database -n xdb -u xdbu -p xxx
```

If no credentials are given, the installer automatically creates a new database. This requires MySQL root credentials. To avoid having to type those every time you run the installer, it is common practice to place them in a file in the users' home folder (`~/.my.cnf`). This file will be picked up by MySQL, allowing us to execute commands without providing username and password.

Again, needless to say that this can be a bit dangerous if other people gain access to this file, so only do this if you're confident that this can't happen on your server.

Here's how to do it. As the local user, run:

```shell
cat > ~/.my.cnf << EOF
[client]
user=root
password=**********
EOF
```

Make file only readable to you:
```shell
chown 400 ~/.my.cnf
```

You may need to restart MySQL for this to take effect. To test if it works:

```shell
mysql -e 'SHOW DATABASES;'
```

## Gitify

Essential for growing any seed, is of course: water. The digital equivalent of water in the Romanesco ecosystem is called [Gitify][9]. Gitify (together with Git) functions as the irrigation system, moving content and elements around and making sure everything is up to date.

Gitify works by extracting data from the database into physical files on your hard drive. This can then be managed and monitored by Git, the most widely used version control system in existence. Git allows you to keep track of all your changes, merge differences between environments, revert your data to previous states and many more useful things. It's the Finnish army knife of the digital realm.

So what Gitify basically does, is to leverage the power of Git to transport data back and forth between MODX installations. This can be between a development and a live server for example, but Romanesco also uses Gitify to create new projects and apply changes to existing ones.

Long story short: it's an indispensable tool, so we need to install it first. Double check that you've defined a suitable Gitify path in config.sh and then run the following command:

```shell
./romanesco plant gitify
```

>**NB:** At this point, a customized fork of Gitify is used, containing a few abilities that haven't been merged with the main repository. So if you're using Gitify already, you can't use it for installing Romanesco.
> To avoid conflicts, please install the forked version separately. This can be done by defining a gitifyPath to a new (non-existing) location in config.sh and then running the `plant gitify` command.
> The installer only references the customized version directly (with full path), so your original, global Gitify command will continue to work as before (using the main repository).

## NodeJS

---

For more information, visit: https://romanesco.info/

[1]: https://modx.com/get-modx/
[2]: https://modmore.com/contentblocks/
[3]: https://github.com/hugopeek/romanesco-patterns
[4]: https://fomantic-ui.com/
[5]: https://github.com/hugopeek/romanesco-theme
[6]: https://github.com/hugopeek/romanesco-soil
[7]: https://modmore.com/redactor/
[8]: https://modmore.com/free-development-licenses/
[9]: https://github.com/modmore/Gitify