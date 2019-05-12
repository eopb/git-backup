# `git-backup`
Program for backing up all your GitHub repositories.

[![pipeline status](https://gitlab.com/efunb/git-backup/badges/master/pipeline.svg)](https://gitlab.com/efunb/read_input/commits/stable)

## Help

If you run into any issues or need help with using `git-backup` in your project please email [incoming+efunb-git-backup-12293303-issue-@incoming.gitlab.com](incoming+efunb-git-backup-12293303-issue-@incoming.gitlab.com)

## Why

I found no easy way of backing up some of my GitHub repositories so I made this program to make the job easy.

I have also found this program useful for downloading all my repositories onto a new laptop when preparing for a holiday.

## Install
### Compile yourself

```sh
git clone https://gitlab.com/efunb/git-backup.git
cd git-backup/
stack install .
```

### Download

[Download for Linux](https://gitlab.com/efunb/git-backup/-/jobs/artifacts/stable/raw/files/git-backup-exe?job=linux-optimized)

## How to use

```sh
git-backup-exe [username]
```
for example
```sh
git-backup-exe ethanboxx
```

## **Warning**

**If you are viewing this from GitHub then this is a read only copy. Please contribute to the GitLab copy [here](https://gitlab.com/efunb/git-backup).**