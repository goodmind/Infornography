Infornography
=============

The problem? `screenfetch` is more than 3.8k standard lines of code.

There are window managers that are less than this. For a script which reports system information, this is simply too large and needlessly complex.

Furthermore, `screenfetch` is designed to function on a great variety of platforms, so it's not always immediately clear what code affects the platform you're currently running on.

`infornography` aims to remedy this. It is to be written entirely in Scheme and target one, or very few, platforms. This way we avoid needing excessive code to deal with the quirks of the many operating systems and distributions in circulation.

### Why Scheme?
It's the most hackable language there is.

### Does this really matter so much?
No. But I'd rather write something small that I can edit later than learn the  codebase of `screenfetch`. It's also something to do.

### Does it compile?
`raco exe infornography.rkt` will build a native binary.
I might put some up somewhere in the future, maybe.

### What about Archey?
`archey` seems to follow more closely the principles of KISS, however it's designed only for Arch Linux. We'd like to be a little more broad, but just a little.

### Known issues/notes
- OSX and *BSD support has been dropped for now, seperate scripts for    different systems will be made soon.

<center>
<img
  alt="Infornography macOS"
  src="http://hnng.moe/f/F21" />
<img
  alt="Infornography"
  width="89%"
  src="http://hnng.moe/f/F23" />
</center>