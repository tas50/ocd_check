ocd_check
=========

Obsessive Cookbook (version) Disorder Check - Checks your local chef repo versions against the Chef Community Site

##App Usage

The app can be controlled either by command line arguments or an ocdcheck.yml configuration file.

####Command Line Arguments

####ocdcheck.yml Configuration File
The app will look for a YAML config file located in the current working directory followed by the ~/.chef/ directory.  If neither of these exist it will fall back to the command line arguments.  You can also specify the location of the config file using the -c argument.

