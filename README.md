# Infornography

<center>
<img
  alt="Infornography"
  src="http://hnng.moe/f/Jc6" />
</center>

[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> Lightweight screenfetch/archey replacement in Racket, only has features that are absolutely necessary.

The problem? `screenfetch` is more than 3.8k standard lines of code.

There are window managers that are less than this. For a script which reports system information, this is simply too large and needlessly complex.

Furthermore, `screenfetch` is designed to function on a great variety of platforms, so it's not always immediately clear what code affects the platform you're currently running on.

`infornography` aims to remedy this. It is to be written entirely in Racket and target one, or very few, platforms. This way we avoid needing excessive code to deal with the quirks of the many operating systems and distributions in circulation.

## Background

### Why Racket?
It's the most hackable language there is.

### Does this really matter so much?
No. But I'd rather write something small that I can edit later than learn the  codebase of `screenfetch`. It's also something to do.

### Does it compile?
`raco exe infornography.rkt` will build a native binary.
I might put some up somewhere in the future, maybe.

### What about Archey?
`archey` seems to follow more closely the principles of KISS, however it's designed only for Arch Linux. We'd like to be a little more broad, but just a little.

### Known issues/notes
- See [Notes page](https://github.com/goodmind/Infornography/projects/1)

## Install

### macOS

You need [Homebrew](http://brew.sh) to install it
    
    $ brew tap goodmind/homebrew-wired
    $ brew install infornography

### Archlinux

You can use [Yaourt](https://archlinux.fr/yaourt-en) or your preferred [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers)

    $ yaourt -S infornography
    
## Usage

    $ infornography

## Contribute

PRs accepted

## License

[MIT](LICENSE)
