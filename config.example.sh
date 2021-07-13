# REPOSITORIES
# ==============================================================================

gitPathSoil=https://github.com/hugopeek/romanesco-soil.git
gitPathData=https://github.com/hugopeek/romanesco-data.git
gitPathTheme=https://github.com/hugopeek/romanesco-theme.git

cbHeadingImagePath=https://github.com/hugopeek/cbheadingimage.git
romanescoBackyardPath=https://github.com/hugopeek/romanesco-backyard.git
htmlPageDomPath=https://github.com/hugopeek/htmlpagedom.git
mailBlocksPath=https://github.com/hugopeek/mailblocks.git


# ENVIRONMENT
# ==============================================================================

# Each project is installed under its own Linux user by default. This means that
# a new Linux user will be created during setup, with a separate home folder.
# The purpose of this is to isolate multiple installations on the same server.
# Each installation has a different user. And each user can only access its own
# installation. Therefore, if one installation is compromised, it's still very
# difficult for an attacker to target any of the other installations.

# Sometimes though, you may want to override this behaviour. On your local
# computer for example, it makes little sense to compartmentalize projects.
# To run all installations under the same user, enter the username below.
#localUser=hugo

# Tip: if you also run Nginx (or Apache) under this user, you barely need to
# fiddle with permissions anymore.

# By default, PHP is also run under the isolated Linux user. This has the same
# security benefits as mentioned above, plus it separates server load between
# projects. If PHP hangs for some reason (timeouts, memory issues, etc), it's
# much less likely to affect other installations. It's also easier to monitor
# individual installations this way, and you can scale up server resources per
# project by managing their configurations separately.

# Again, this behaviour can be overridden by specifying a shared PHP user below.
#phpUser=hugo

# PHP versions can differ per environment, so please specify the local version.
phpVersion=7.4

# If you set a $localUser, you must also define an absolute path to your local
# WWW folder. This is the folder containing all your projects. New projects will
# be placed there by the installer, in a sub folder with the project name.
#wwwPath=/var/www/

# Path to the local Gitify folder containing my forked version (!). See readme
# for more details.
gitifyPath=/opt/gitify

# Default domain extension, if no custom domain is defined.
# For example: 'loc' will result in the local URL 'project-name.loc'.
domainExt=loc


# MODX
# ==============================================================================

modxVersion=2.8.3-pl

defaultUser=Hugo
defaultEmail=comms@fractal-farming.com


# PACKAGES
# ==============================================================================

# API key for downloading ModMore packages.
modmoreUser=USERNAME_REFERENCE
modmoreAPIkey=GENERATED_API_KEY

# The installer needs a few packages that are not (yet) listed in any official
# repository. They are created with GPM and available on Github / Gitlab.
# To ensure the latest version is always available, please specify a local
# directory where these packages can be found. If a package is not present in
# this folder, it will be cloned with Git.
gpmPath=/var/packages

# Each time you install a new project, the required extras are downloaded from
# the official MODX repository. This can take a while, depending on where you
# are in the world and what kind of internet connection you have.
# You can speed this up significantly by defining a local packages folder that
# already includes these extras (in another local installation, for example).
# If $packagesPath is set, the installer will not download anything, but copy
# the transport packages from this donor location instead.
# Beware though! The package provider (MODX) will no longer be attached to the
# packages, so package updates will not appear in the grid as they usually
# would. Packages on the donor location might also become outdated, so this
# feature is only meant for testing purposes. Leave blank otherwise!
#packagesPath=/var/www/apo-sunrise/core/packages

# Another note: ModMore packages cannot be installed this way. So you still
# need an internet connection to download ContentBlocks and Redactor.


# THEME
# ==============================================================================

# You can tweak the styling of the Fomantic UI theme to suit your own visual
# identity. If you already know some of these variables, you can instruct the
# installer to apply them right away.

# Specify HEX color codes, without the # character. Make sure the colors are
# either light / dark enough for black / inverted text to be visible on.
#themeColorPrimary=ff6c56
#themeColorPrimaryLight=f7f1ec
#themeColorSecondary=
#themeColorSecondaryLight=

# Specify a Google webfont for all headings and / or regular content the site.
# You can enter just the name (i.e.: Ubuntu) or a string containing font weights
# and character subset too. Use the following syntax for that:
# Ubuntu|300,700,300italic,700italic|latin,cyrillic
# NB: font name is case sensitive! Make sure you use the exact same name as
# listed on Google Webfonts.
#themeFontHeader=
#themeFontPage=


# DATA
# ==============================================================================

# Define a custom homepage. This needs to be a Gitify data file, containing a
# resource with ID: 1 and the HTML you'd like to parse in the content area.
#welcomePage=
