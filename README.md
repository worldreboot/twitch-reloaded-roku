![Splash](https://i.imgur.com/LXhqf4J.png)

![Overview](https://media.discordapp.net/attachments/791115330680389693/803760770931228692/preview.jpg?width=831&height=467)

# 🔮 Twoku (for Roku)
An Improvable™ Twitch app for Roku. Still buggy, so feel free to suggest improvements (and code and features). Unfortunately, the code is very disorganized and messy because the original developers knew nothing about Roku development when they started on this. The goal was to get a somewhat functioning Twitch app for Roku as fast as possible (because they wanted to watch Twitch on Roku immediately). They basically hacked on it until it <em>just werked</em>.

Also, the original devs have not been very active with this project recently. So if you can contribute, please do. There are still many desirable features that have not been added (just go on the Discord).

## Discord
If you have any questions or comments (or phishing links):

[![Discord](https://discordapp.com/api/guilds/721488568303878155/widget.png?style=banner2)](https://discord.gg/kV5SXkZ)

## Support
If you would like to support Twoku:

 [![Support with PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=YRPQDG5UY26DS&currency_code=CAD&source=url)

## Contributing
If you have an idea (feature, etc.) that you would like to contribute (with code) to the project with, DM one of the developers on the Discord with your idea. Otherwise, if you just have an idea, post it in the ```#features``` channel on the Discord server. You can also just fork this repository as its up to date and implement the feature yourself.

## How to Install
<em>The first two access codes below might not work for users in Mexico and Brazil due to regional restrictions.</em>
### With Access Code
Install with access code: TWOKU (https://my.roku.com/account/add?channel=TWOKU)

Beta version: TTWOKU (https://my.roku.com/account/add?channel=TTWOKU)

Twoku Public (should be available for users in Mexico and Brazil): C6ZVZD (https://my.roku.com/account/add?channel=C6ZVZD)

### Manual Developer Install
1. [Enable developer mode for Roku](https://blog.roku.com/developer/developer-setup-guide)
2. Log into your Roku from your browser using IP from previous step (http://192.168.x.x)
3. ZIP (into a ZIP file) all contents of this repo (you do not have to include README.md) (using 7-Zip, WinRAR, etc.). Do not include extra top level directories in the ZIP file, otherwise you may get the error: "Install Failure: No manifest. Invalid package.".
4. Upload previous ZIP file in Roku Development Application Installer (step 2)
5. Press Install
6. Twoku should now be installed on your Roku

## Supported Features
* Browsing live channels and categories by viewer count (press down to load more)
* Search (with buggy auto-complete)
* Viewing followed live streamers
* Viewing popular clips from the past 7 days for each category
* Chat (only for live streams)
* VODs (except subscriber-only)

## Notable Unsupported Features
* All clip functionality not mentioned
* Chat (for VODs)
* Chat alignment settings (can only be overlayed on stream)
* Subscriber-only VODs
* Everything else not mentioned
