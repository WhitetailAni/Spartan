# Spartan now supports localization! Please contribute to localizing it!

# Spartan
tvOS file browser built in SwiftUI. Supports tvOS 13.0+. Will not work in 
a simulator.

Note that tvOS 13.x has a different user experience than 14.0+ due to SwiftUI limitations - it is still capable of everything, though.

What it currently lets you do:

- Browse file directory
- View and edit text files
- Watch videos (and view info)
- Play audio (and view metadata)
- Create folders
- Create files
- Create symlinks
- Save folders or files to Favorites
- Get info about a file
- Rename a file
- Move a file or files to Trash (or if in Trash, delete them)
- Move a file or files to a given directory (if a single file, you can rename it)
- Copy a file to a new filepath (and optionally, rename it)
- View images (and view info)
- View plist files (both xml and bplist)
- Spawn binaries
- Compress and uncompress .zip archives
- Search a directory and its subdirectories for a file or directory
- View all mounted devices
- Hex editor
- Font viewer
- Asset catalog name
- Display app icons/names/bundle IDs in container directories and /Applications
- Perform FS actions outside of /var/mobile (yes we have root helper!!!!)
There's probably more, I lost track.

TODO:
- Plist editor //everything done but dictionary which is behaving weirdly
- fix asset catalog viewer
- SFTP server

It requires an Apple TV that is either jailbroken or has a kpf applied and 
is compatible with MDC to build and run, *currently*. Work is being done 
to add support for different schemes - jailbroken, tipa, jailed, etc.

How to use:
1. Clone the repository and open it in Xcode (15.0+ required).
2. Get the patched tvOS 17.0 sdk from 
[https://github.com/RealKGB/sdks-tvos](sdks-tvos).
3. Build and run to your Apple TV.

Good luck have fun. Hopefully this isn't the only tvOS file browser ever.

[https://www.buymeacoffee.com/whitetailani](Donations if you want.)
