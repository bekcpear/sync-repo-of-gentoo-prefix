# Sync repositories from scratch for gentoo-prefix project

## init

1. make scripts
   ```bash
   ./make.sh </path/to/prefix/root>
   ```
   > The default executing user is `portage`, if you need to specify a different
   > one, please execute with:
   > ```bash
   > ./make.sh </path/to/prefix/root> <the-username>
   > ```
2. edit `./dist/env.sh`
3. `cp ./gpg.conf /path/to/portage/home/dir/.gnupg/`
4. `./update-pub-keys` used to get the pub keys of developers
5. `./update-pub-keys force` used to update local keychains
6. init repos
   ```bash
   cd /<prefix>/var/db/repos/
   git clone --depth 1 https://github.com/gentoo/gentoo
   cd ./gentoo/metadata/
   git clone --depth 1 https://anongit.gentoo.org/git/data/dtd.git
   git clone --depth 1 https://anongit.gentoo.org/git/data/glsa.git
   git clone --depth 1 https://anongit.gentoo.org/git/data/gentoo-news.git news
   git clone --depth 1 https://anongit.gentoo.org/git/data/xml-schema.git
   cd /path/to/the/root/of/this/repo # just for example
   git clone --depth 1 https://github.com/gentoo/prefix
   ```
7. `./sync-repo` to build gentoo_prefix repo

## usage

* `./update-pub-keys` for daily pubkey updating
* `./sync-repo` for daily repo syncing
