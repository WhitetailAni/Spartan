# Spartan
tvOS file browser thrown together in SwiftUI. Supports tvOS 14.0+.
I want it to support 13.0+ but ContextMenus are 14.0+. If you want to backport ContextMenus and make a pr, go ahead.
I have an idea for eliminating ContextMenus but don't have time to implement it.
Aside from ContextMenus, everything supports 13.0+

What it currently lets you do:

1. Browse file directory
2. Read text files
3. Watch videos (and get info about them)
4. Play audio (and view metadata)
5. Create folders
6. Create files
7. Save folders or files to Favorites
8. Get info about a file
9. Rename a file
10. Move a file to Trash (or if it's in Trash, permanently delete it)
11. Move a file to a new filepath (and optionally, rename it)
12. Copy a file to a new filepath (and optionally, rename it)
13. View images

TODO:
1. Don't assume a filepath is a directory in ContentView (you can specify a filepath to a non-folder and it will open the proper view)
2. Add info to ImageView
3. Root helper
4. more

By default it's sandboxed, so you will need a tvOS jailbreak to use it unless you're fine with just modifying what's in the app's data directory. It's set to open /var/mobile/ by default. Moving, renaming, and copying require you being in /var/mobile/ until I add a root helper

Xcode project requires Xcode 14.3+

Good luck have fun. Hopefully this isn't the only tvOS file browser ever.
