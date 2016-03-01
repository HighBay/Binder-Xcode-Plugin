# Binder Xcode Plugin
This repository gives you access to a xcode plugin that will make it easier to use [Binder](https://www.nuget.org/packages/Binder/) within Xcode by doing most of the work in regards to adding and removing of the Binder files for you.

--- Swift only instructions, Obj-C may differ ---

## Install Binder Xcode Plugin
1. Download BinderPlugin.xcplugin.zip
2. Unzip plugin file
3. Move plugin file to /Library/Application Support/Developer/Shared/Xcode/Plug-ins inside your user folder (The library folder is a hidden folder, click [here](http://www.wikihow.com/Show-Hidden-Files-and-Folders-on-Mac-OS-X) for help; if the Plug-ins folder does not exist create it)
4. Restart Xcode and you should have two new fields within your Xcode 'File' menu

## Add Binder Reference
1. In Xcode go to 'File > Add Binder Reference' or CTRL+SHIFT+B
2. When prompted enter your Binder endpoint (e.g. https://yourwebsite.com/YourProjectName/Binder/Binder/IOS), which is just a link to your Binder iOS Data Layer
3. Click 'Add Binder' and wait until Binder is downloaded and added. The adding process is finished when all your groups/folder in your Xcode navigator collapse
4. Add the Alamofire iOS framework in the 'Embedded Binaries' inside your project target's 'General' tab
5. You're ready to use Binder. (Make sure to import Alamofire wherever you make a Binder web call)

## Remove Binder Reference 
1. In Xcode go to 'File > Remove Binder Reference', which will remove all associated files from your project directory
2. Delete the Binder group from project navigator

## Update Binder
1. Follow instruction from 'Remove Binder Reference' section to remove Binder
2. Follow instructions from 'Add Binder Reference' section, which will retain your Binder URL as long as Xcode is running. If Xcode has been restarted after the last time the Binder reference was added the URL will have to be entered again.
