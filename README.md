# Spartan
tvOS file browser thrown together in SwiftUI. Supports tvOS 14.0+.
I want it to support 13.0+ but ContextMenus are 14.0+. If you want to backport ContextMenus and make a pr, go ahead.
I have an idea for eliminating ContextMenus but don't have time to implement it.
Aside from ContextMenus, everything supports 13.0+

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

TODO:
1. Don't assume a filepath is a directory in ContentView (you can specify a filepath to a non-folder and it will open the proper view)
(this will probably never happen)
2. Add info to ImageView and VideoPlayerView
3. Plist editor
4. Spawn binaries
5. Root helper
6. more

By default it's sandboxed, so you will need a tvOS jailbreak to use it unless you're fine with just modifying what's in the app's data directory. Since it currently lacks a root helper, any actions that write to the filesystem must be within /var/mobile/.
It will open /var/mobile/ by default, unless you are sandboxed, in which case it will open the app's data directory.

Xcode project requires Xcode 14.3+. Has one dependency, Zip.

Good luck have fun. Hopefully this isn't the only tvOS file browser ever.
