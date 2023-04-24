# Spartan now supports localization! Please contribute to localizing it!

# Spartan
tvOS file browser thrown together in SwiftUI. Supports tvOS 13.0+

Note that tvOS 13.x is more limited compared to 14.0+. It is still capable of everything though.

What it currently lets you do:

1. Browse file directory
2. View and edit text files
3. Watch videos
4. Play audio (and view metadata)
5. Create folders
6. Create files
7. Save folders or files to Favorites
8. Get info about a file
9. Rename a file
10. Move a file or files to Trash (or if in Trash, delete them)
11. Move a file or files to a given directory (if a single file, you can rename it)
12. Copy a file to a new filepath (and optionally, rename it)
13. View images
14. View plist files (both xml and bplist)
15. //BROKEN Execute binaries
16. Compress and uncompress .zip archives
17. Search a directory and its subdirectories for a file or directory
There's probably more, I lost track.

TODO:
1. Don't assume a filepath is a directory in ContentView (you can specify a filepath to a non-folder and it will open the proper view)
(this will probably never happen)
2. Add info to ImageView and VideoPlayerView
3. Plist editor
4. Spawn binaries
5. Root helper
6. Read app list to show what app container is which if in (/private)/var/containers or (/private)/var/mobile/
7. more

I keep doing things OTHER than the todo list. Fun!

By default it's sandboxed, so you will need a tvOS jailbreak to use it unless you're fine with just modifying what's in the app's data directory. Since it currently lacks a root helper, any actions that write to the filesystem must be within /var/mobile/.
It will open /var/mobile/ by default, unless you are sandboxed, in which case it will open the app's data directory.

How to use:
1. Clone the repository and open it in Xcode (14.3+ required).
2. Enter the Xcode.app folder and find the AppleTVOS SDK. Locate /usr/include/spawn.h, give it write permissions, and remove the listings that mark it as unavailable on tvOS.
3. Build and run to your Apple TV.

Good luck have fun. Hopefully this isn't the only tvOS file browser ever.
