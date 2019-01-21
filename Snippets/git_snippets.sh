#!/bin/bash


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


#  __  __   _____   _____    _____     ____    _____
# |  \/  | |_   _| |  __ \  |  __ \   / __ \  |  __ \
# | \  / |   | |   | |__) | | |__) | | |  | | | |__) |
# | |\/| |   | |   |  _  /  |  _  /  | |  | | |  _  /
# | |  | |  _| |_  | | \ \  | | \ \  | |__| | | | \ \
# |_|  |_| |_____| |_|  \_\ |_|  \_\  \____/  |_|  \_\
#
###############################################################################
#  _ _  ___  ___  ___ __   __   _    _____  ___    ___   ___   ___  _  __ _ _
# ( | )| _ \| _ \|_ _|\ \ / /  /_\  |_   _|| __|  | __| / _ \ | _ \| |/ /( | )
#  V V |  _/|   / | |  \ V /  / _ \   | |  | _|   | _| | (_) ||   /| ' <  V V
#      |_|  |_|_\|___|  \_/  /_/ \_\  |_|  |___|  |_|   \___/ |_|_\|_|\_\
#
#------------------------------------------------------------------------------
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




#==============================================================================



###############################################################################
#  _____    ______   _        ______   _______   _____   _   _    _____
# |  __ \  |  ____| | |      |  ____| |__   __| |_   _| | \ | |  / ____|
# | |  | | | |__    | |      | |__       | |      | |   |  \| | | |  __
# | |  | | |  __|   | |      |  __|      | |      | |   | . ` | | | |_ |
# | |__| | | |____  | |____  | |____     | |     _| |_  | |\  | | |__| |
# |_____/  |______| |______| |______|    |_|    |_____| |_| \_|  \_____|
#
###############################################################################
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


###############################################################################
#  _____    ______   __  __    ____    _______   ______
# |  __ \  |  ____| |  \/  |  / __ \  |__   __| |  ____|
# | |__) | | |__    | \  / | | |  | |    | |    | |__
# |  _  /  |  __|   | |\/| | | |  | |    | |    |  __|
# | | \ \  | |____  | |  | | | |__| |    | |    | |____
# |_|  \_\ |______| |_|  |_|  \____/     |_|    |______|
#
###############################################################################


#------------------------------------------------------------------------------
#  ___   ___     _     _  _    ___   _  _
# | _ ) | _ \   /_\   | \| |  / __| | || |
# | _ \ |   /  / _ \  | .` | | (__  | __ |
# |___/ |_|_\ /_/ \_\ |_|\_|  \___| |_||_|
#
#------------------------------------------------------------------------------

# push a local branch
#git push <remote-name> <local-branch-name>:<remote-branch-name>
git checkout -b <branch>
git push -u <remote> <branch>

# To pull all new remote branches from remote:
git remote update


###############################################################################
#    __  __               _____    _____    _____
#   |  \/  |     /\      / ____|  |_   _|  / ____|
#   | \  / |    /  \    | |  __     | |   | |
#   | |\/| |   / /\ \   | | |_ |    | |   | |
#   | |  | |  / ____ \  | |__| |   _| |_  | |____
#   |_|  |_| /_/    \_\  \_____|  |_____|  \_____|
#
###############################################################################

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
