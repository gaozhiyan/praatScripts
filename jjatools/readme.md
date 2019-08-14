JJATools
========

> **This plugin has been discontinued, and will receive no further support or**
> **changes. It has been broken down into a multiplicity of individual plugins**
> **which are currently being distributed via CPrAN at the following URL:**
>
> http://cpran.net
>
> **This repository will remain as is for archival purposes, but please consider**
> **using those plugins instead, which are under active development.**

Version: 1.0.4

## Overview

This plugin for [Praat][] contains a set of some scripts that I have written
which I find to be particularly useful, and that fill in some gaps I've found in
the existing Praat interface.

Since it was first packaged as a plugin in April 2014, it has grown
considerably, and it now includes a much larger set of scripts and procedures
than I initially expected it to have. This has made organizing it a task in
itself, but I think that it is now in a stable enough state for an slow, initial
release. Particularly because I have started using it in a number of other side
projects, and it's slowly starting to get out there.

### Documentation

Not all scripts are thoroughly documented, and whatever documentation does exist
is in the body of the scripts themselves. In the near future, I expect to
document the way the plugin is to be used in the [wiki][] pages of this repository,
so that using it is easier for everyone interested.

[wiki]: https://github.com/jjatria/plugin_jjatools/wiki

For an (incomplete) list of the scripts provided in this plugin, please check
[setup.praat][setup], which lists all the changes made to the UI.

[setup]: https://github.com/jjatria/plugin_jjatools/blob/master/setup.praat

### Using individual scripts

Unlike most plugins out there, I make _heavy_ use of procedures, to avoid
reinventing the wheels I myself have established, and to promote code re-use
as much as I can. This can make extracting particular scripts from this plugin
a bit difficult, so if there's one script you are interested in, I recommend you
install the entire plugin unless you know what you are doing.

### Scripts and procedures

Scripts in this plugin are separated into three large groups, in different
directories:

*  `procedures` contains files with the `.proc` extension, which themselves
   define procedures that can be included into other scripts.

*  `batch` contains files with the `.praat` extension, to be used on a large
   number of files. Some of them take their input from files that have already
   been read into the Object list, and others (most) act on files that are
   individually read from disk. Normally, these _batch_ scripts will just
   provide a wrapper that calls some other script in the background.

*  The remaining directories are named after individual object types, and
   contain scripts that apply (primarily) to that type of object: scripts in the
   `sound` directory are scripts that use (or modify, or query, etc) `Sound`
   objects.
   
### Re-using code in the plugin
   
You are welcome to integrate any script and procedure you find here into your
own work. You can do this by installing the plugin and then using the `include`
directive in your own Praat scripts.

You'll need to have a way to know the full path to the script or procedure
definition, or save your script somewhere it can reach the definiton using a
relative path. Once again, I _do not recommend_ to make external copies of
scripts from this plugin into because that will likely break things. Try to
`include` local versions instead.

The easiest way to include them is if your own script is itself in a plugin,
because in that case you can access the preferences directory (which is in a
platform-dependant location) by simply traversing upwards along the directory 
tree.

To try to make this easier, all scripts and procedures are located in a
sub-directory immediately below the plugin root directory. As long as your own
scripts also follow this rule, then they should all happily be able to include
each other like so:

    include ../../plugin_jjatools/procedures/some_procedure_name.proc

### Hooks (or procedure-redefinition)    
    
Some procedures (notably [`view_each.proc`][view_each], but probably more in the future) make
use of internal procedures as hooks, which you can redefine to modify the 
behaviour of the main procedure to a certain extent. For example, in
`view_each.proc` this allows you to customize what happens when `each` is 
`viewed` without having to modify the procedure itself (or make a local copy, 
which would make me sad).

[view_each]: https://github.com/jjatria/plugin_jjatools/blob/master/procedures/view_each.proc

In order to do this, you must redefine the hook (=procedure) *before* the 
`include` call, so that when the file is read, the internal definitions are 
ignored.

## Installation

If you are using GNU/Linux, and have `git` installed, you can run

    cd ~/.praat-dir
    git clone https://github.com/jjatria/plugin_jjatools.git

and you should be good to go!

If not, then you can use the general instructions below:

1. Download [the contents of the repo][zip] and extract into a folder called
   `plugin_jjatools` in your Praat preferences directory. The exact location of
   the preferences directory depends on your operating system, so please
   [check the documentation][preferences].
   
   This means that the directory structure should look like this:

   ~~~~   
   [preferences directory]
     ├─[other plugins]
     ├─plugin_jjatools
     │   ├─[other directories and files]
     │   └─setup.praat
     ├─buttons5
     └─prefs5
   ~~~~
   
2. Restart Praat.

[praat]: www.praat.org
[preferences]: http://www.fon.hum.uva.nl/praat/manual/preferences_directory.html
[zip]: https://github.com/jjatria/plugin_jjatools/releases/latest
