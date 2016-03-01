# Binder Xcode Plugin
This repository gives you access to a xcode plugin that will make it easier to use [Binder](https://www.nuget.org/packages/Binder/) within Xcode by taking over adding and removing of the Binder files.

--- Swift only instructions, Obj-C may differ ---

## Install Binder Xcode Plugin
1. Download BinderPlugin.xcplugin.zip
2. Unzip plugin file
3. Move plugin file to /Library/Application Support/Developer/Shared/Xcode/Plug-ins inside your user folder (The library folder is a hidden folder; if the Plug-ins folder does not exist create it)
4. Restart Xcode and you should have two new fields within your Xcode 'File' menu

## Add Binder Reference
1. In Xcode go to 'File > Add Binder Reference'
2. When prompted enter your Binder endpoint (e.g. https://yourwebsite.com/YourProjectName/Binder/Binder/IOS), which is just a link to your Binder iOS Data Layer
3. Click 'Add Binder' and wait until Binder is downloaded and added. The adding process is finished when all your groups/folder in your Xcode navigator collapse
4. Add the Alamofire iOS framework in the 'Embedded Binaries' inside your project target's 'General' tab
5. You're ready to use Binder. (Make sure to import Alamofire wherever you make a Binder web call)
