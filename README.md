# `git-backup`
Program for backing up all your GitHub repositories.

[![pipeline status](https://gitlab.com/efunb/git-backup/badges/master/pipeline.svg)](https://gitlab.com/efunb/git-backup/commits/master)

![](working_example.gif)

## Why

I found no easy way of backing up some of my GitHub repositories so I made this program to make the job easy.

I have also found this program useful for downloading all my repositories onto a new laptop when preparing for a holiday.

## Install
### Compile

```sh
stack install .
```

## How to use

```sh
git-backup [username] [--org|--user]
```
for example
```sh
git-backup eopb --user
```

