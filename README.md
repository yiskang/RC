RcFiles
=======

My rc backups for Linux and Mac OSX

Setup
-----

Some paths are git submodules (e.g. `Agents/skills/speak-human-tw`), so clone
with them included:

    git clone --recurse-submodules <url>

If you already cloned without that flag, the submodule directories will be
empty. Populate them with:

    git submodule update --init --recursive
