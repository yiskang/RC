RcFiles
=======

My rc backups for Linux and Mac OSX

Layout
------

    .
    ├── Agents/               Claude Code config
    │   └── skills/           symlinked as ~/.claude/skills
    ├── Git/                  git config
    │   └── .gitignore-xcode
    └── Home/                 dotfiles for $HOME
        ├── .clang_complete
        ├── .screenrc
        ├── .vim/colors/
        ├── .vimrc
        ├── .zsh_aliases
        ├── .zsh_profile
        ├── .zshrc
        └── tmux.conf

Files under `Home/` are symlinked into `$HOME` under the same name;
`tmux.conf` is the exception, linked as `~/.tmux.conf`.

Setup
-----

Some paths are git submodules (e.g. `Agents/skills/speak-human-tw`), so clone
with them included:

    git clone --recurse-submodules <url>

If you already cloned without that flag, the submodule directories will be
empty. Populate them with:

    git submodule update --init --recursive

Submodules use SSH URLs, so a GitHub SSH key must be loaded first — without
one both commands fail with a permission error instead of cloning.

## License

MIT License — see [LICENSE](LICENSE).

## Written by

Eason Kang [in/eason-kang-b4398492/](https://www.linkedin.com/in/eason-kang-b4398492)