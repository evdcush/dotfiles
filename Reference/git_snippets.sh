#!/bin/bash

# push a local branch
#git push <remote-name> <local-branch-name>:<remote-branch-name>
git checkout -b <branch>
git push -u <remote> <branch>

# Create branch with no history/code
# ----------------------------------
git checkout --orphan my_branch

# to unstage automatically added code:
git rm --cached -r .

# to remove automatically added code:
git rm -rf .

# To pull all new remote branches from remote:
git remote update


# Prettier git log, with graphical branching
# ------------------------------------------
git log --graph --decorate --oneline --all

# git diff files from different branches
# --------------------------------------
git diff branch_a branch_b -- my_file.py # can remove -- if compare work tree

# Undo last merge
# ---------------
git reset --hard ORIG_HEAD

# Change commit date
# ------------------
git commit --amend --date "Wed Jan 7 11:21:46 2019 -0800"


# -------------------------------------
# "Merge" single file from other_branch
# -------------------------------------
#==== Stage files that would be merged by git, without committing yet
#     choose which ones you want
git merge --no-ff --no-commit other_branch

# if you dont want one of the files from the above command:
git checkout HEAD file1

#==== Just want the version from other_branch (overwrites)
git checkout other_branch file1

#========================================


# Keep a file in git, but do not track history
# --------------------------------------------
# MORE TROUBLE THAN IT WORTH, DONT
#git update-index --skip-worktree <file_name>
#git update-index --no-skip-worktree <file_name> # opposite
# it will read as up to date, and changes will not be flagged as changes

#==== to keep a file in a git repo, but will not update and do not want updates:
# git update-index --assume-unchanged <file_name>
# git update-index --no-assume-unchanged <file_name> # opposite

#==== How to list files ignored via --skip-worktree
git ls-files -v . | grep ^S


# See what files are tracked in git history
# (even deleted files)
# -----------------------------------------
git log --pretty=format: --name-only --diff-filter=A | sort - | sed '/^$/d'

#=============================================================================#
#                  _   _                                           _          #
#           __ _  (_) | |_            ___   _ __   _   _   _ __   | |_        #
#          / _` | | | | __|  _____   / __| | '__| | | | | | '_ \  | __|       #
#         | (_| | | | | |_  |_____| | (__  | |    | |_| | | |_) | | |_        #
#          \__, | |_|  \__|          \___| |_|     \__, | | .__/   \__|       #
#          |___/                                   |___/  |_|                 #
#                                                                             #
#=============================================================================#

# Install
sudo apt install git-crypt

# Setting up git-crypt repo
# =========================
# make git repo or navigate to your repo
mkdir sample_repo && cd sample_repo
git init

# specify files to encrypt via .gitattributes file
# in repo root
touch .gitattributes
echo "secretfile filter=git-crypt diff=git-crypt" >> .gitattributes
echo "*.key filter=git-crypt diff=git-crypt" >> .gitattributes
git add .gitattributes
git commit -m 'git-crypt attrs'

# dummy files
touch publicfile
touch secretfile
touch nuclear_launch.key


# initialize git-crypt
git-crypt init  # Generating key...

# Now 'secretfile' and any file with ext '.key' are encrypted by git-crypt
git-crypt status
#     encrypted: nuclear_launch.key
# not encrypted: publicfile
#     encrypted: secretfile
# not encrypted: .gitattributes

# Furthermore, the repo is in a "locked" state

# WARNING:
#  you MUST commit changes to .gitattributes before target files
#  are encrypted
git add secretfile
git add nuclear_launch.key


# Configuring users
# =================
# I prefer the shared key approach
git-crypt export-key ../sample_repo_gckey
git-crypt unlock ../sample_repo_gckey

# ADD FILES IN UNLOCKED STATE, then lock

# Encrypting directories
# ======================
# COMMON GOTCHA:
#  simply adding `secret_dir/* filter=git-crypt diff=git-crypt`
#   WILL NOT ENCRYPT ALL CONTENTS IN secret_dir  -- namely, subdirs will not be encrypt
#  to encrypt ALL contents, you must add the following
#  to secret_dir/.gitattributes:
* filter=git-crypt diff=git-crypt
.gitattributes !filter !diff  # this line necessary to insure .gitattributes file is not encrypted


#=============================================================================#
#                    __  __   _                                               #
#                   |  \/  | (_)  _ __   _ __    ___    _ __                  #
#                   | |\/| | | | | '__| | '__|  / _ \  | '__|                 #
#                   | |  | | | | | |    | |    | (_) | | |                    #
#                   |_|  |_| |_| |_|    |_|     \___/  |_|                    #
#                                                                             #
#=============================================================================#
# How I make a "private fork"
#   Reference: https://stackoverflow.com/a/30352360/6880404

# 1. Create a new repo (let's call it `private-repo`) via the Github UI:
# ------------
git clone --bare https://github.com/exampleuser/public-repo.git
cd public-repo.git
git push --mirror https://github.com/yourname/private-repo.git
cd ..
rm -rf public-repo.git


# 2. Clone the private repo so you can work on it:
# ------------
git clone https://github.com/yourname/private-repo.git
cd private-repo
make some changes
git commit
git push origin master

# 3. To pull new hotness from the public repo:
# ------------
cd private-repo
git remote add public https://github.com/exampleuser/public-repo.git
git pull public master # Creates a merge commit
git push origin master
# Awesome, your private repo now has the latest code from the
#  public repo plus your changes!

# 4. Finally, to create a pull request private repo -> public repo:
# -------------
# The only way to create a pull request is to have push access to the
#  public repo.
# This is because you need to push to a branch there
git clone https://github.com/exampleuser/public-repo.git
cd public-repo
git remote add private_repo_yourname https://github.com/yourname/private-repo.git
git checkout -b pull_request_yourname
git pull private_repo_yourname master
git push origin pull_request_yourname
# Now simply create a pull request via the Github UI for public-repo


#=============================================================================#
#          ____    _____   _       _____   _____   ___    ___    _   _        #
#         |  _ \  | ____| | |     | ____| |_   _| |_ _|  / _ \  | \ | |       #
#         | | | | |  _|   | |     |  _|     | |    | |  | | | | |  \| |       #
#         | |_| | | |___  | |___  | |___    | |    | |  | |_| | | |\  |       #
#         |____/  |_____| |_____| |_____|   |_|   |___|  \___/  |_| \_|       #
#                                                                             #
#=============================================================================#

# reference: https://stackoverflow.com/q/2100907/6880404
#------------------------------------------------------------------------------
# Use this to check for large files or dirs
#------------------------------------------------------------------------------
git rev-list --objects --all \
| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
| sed -n 's/^blob //p' \
| sort --numeric-sort --key=2 \
| cut -c 1-12,41- \
| numfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest

# WARNING: I have only done this as the sole user of a private repo, YMMV

#------------------------------------------------------------------------------
# Removing files from git history
#------------------------------------------------------------------------------
# Removing a file, or directory contents from history completely

#===== Removing a file:
#git filter-branch --force --index-filter 'git rm -rf --ignore-unmatch my_file' --prune-empty --tag-name-filter cat -- --all

#===== Removing all files in my_dir:
#git filter-branch --force --index-filter 'git rm -rf --ignore-unmatch my_dir/*' --prune-empty --tag-name-filter cat -- --all

#===== (What I have actually used):
#git filter-branch --tree-filter 'rm -rf my_dir/*' --prune-empty  -- --all
#git filter-branch --tree-filter 'rm -f stuff.rst more_stuff.md resources.yml *.pdf' --prune-empty  -- --all

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NOTE: THE ABOVE COMMANDS WILL WORK HOWEVER...
#  I just use `git-obliterate` now from the `git-extras` package
#  much simpler. Still follow the commands below

# AFTER EACH filter-branch
rm -rf .git/refs/original

# FINALLY
git reflog expire --expire=now --all
git gc --prune=now
git gc --aggressive --prune=now
#git push --force origin master
git push --all --prune --force  # will delete all branches not in local
# MUST CLONE UPDATED REPO

#------------------------------------------------------------------------------
# Delete misc:
#------------------------------------------------------------------------------
#===== Delete a tag on github
git fetch # if you do not see the tag on local
git tag -d <tag-name>
git push origin :<tag-name>

# if tag name is same as branch:
git tag -d <tag-name>
git push origin :refs/tags/<tag-name>

#==== Delete all local untracked files in repo
git clean -n # to see what will be deleted
git clean -f # to delete

#==== Delete branch
git push --delete <remote_name> <branch_name> # remote
git branch -d <branch_name> # local


#=============================================================================#
#                            __  __   _                                       #
#                           |  \/  | (_)  ___    ___                          #
#                           | |\/| | | | / __|  / __|                         #
#                           | |  | | | | \__ \ | (__                          #
#                           |_|  |_| |_| |___/  \___|                         #
#                                                                             #
#=============================================================================#

# Set global git ignore
# ---------------------
git config --global core.excludesfile ~/.Dots/global_gitignore

# Squash/drop all commits to one commit
# -------------------------------------
git rebase --root -i  # squash or drop for all commits save first


# Get list of largest objects in git repo
#-----------------------------------------
# great for pruning git tree when it becomes bloated with all those
#  notebooks with cell outputs of high-dpi pyplot 3D mplots you
#  forgot to clear
#
# > Credit:
#   User: https://stackoverflow.com/users/380229/raphinesse
#   Link: https://stackoverflow.com/a/42544963/6880404
git rev-list --objects --all \
| git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' \
| sed -n 's/^blob //p' \
| sort --numeric-sort --key=2 \
| cut -c 1-12,41- \
| numfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest


# Script/Cmd to replace all author
# --------------------------------
#!/bin/sh

git filter-branch --env-filter '
OLD_EMAIL="your-old-email@example.com"
CORRECT_NAME="Your Correct Name"
CORRECT_EMAIL="your-correct-email@example.com"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
