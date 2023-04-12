# Spartan
tvOS file browser thrown together in SwiftUI. Supports tvOS 14.0+.
I want it to support 13.0+ but ContextMenus are 14.0+. If you want to backport ContextMenus and make a pr, go ahead.
I have an idea for eliminating ContextMenus but don't have time to implement it

What it currently lets you do:

1. Browse file directory
2. Read text files
3. Watch videos (and get info about them)
4. Create folders
5. Create files
6. Save folders or files to Favorites
7. Get info about a file
8. Rename a file
9. Move a file to Trash (or if it's in Trash, permanently delete it)
10. Move a file to a new filepath (and optionally, rename it)
11. Copy a file to a new filepath (and optionally, rename it)
12. View images
13. AT SOME POINT: Play audio

TODO:
1. Don't assume a filepath is a directory in ContentView (you can specify a filepath to a non-folder and it will open the proper view)
2. Fix AudioPlayerView
3. Add info to ImageView
4. more to come

By default it's sandboxed, so you will need a tvOS jailbreak to use it unless you're fine with just modifying what's in the app's data directory. It's set to open /var/mobile/ by default.

To change path, manually input the path at the top - make sure to append a / to the end or opening files doesn't work (this will be done automatically later most likely). Can read most text files if they support UTF-8

Xcode project requires Xcode 14.3+

Good luck have fun. Hopefully this isn't the only tvOS file browser ever.
