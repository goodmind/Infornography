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

### What about Archey?
`archey` seems to follow more closely the principles of KISS, however it's designed only for Arch Linux. We'd like to be a little more broad, but just a little.

### Why does the script have a ton of output before the art?
Because there's no good standard for #! (shebang) lines.
To fix this, you can compile the script to a binary `csc infornography.scm` or create your own wrapper that calls `csi -script infornography.scm`

### Known issues/notes
This script tries to be compatible with both GNU/Linux and FreeBSD.
- On some platforms the 'regex' egg is required. This can be installed
via `chicken-install regex`.
