# BlackBoard* BS
\* Not affiliated with BlackBoard Inc.

Fill in the gaps with this handy Chrome Extension for BlackBoard!

Currently it only performs one function - figuring out which group a student
is in (by name). This can be helpful when grading assignments that are
accidentally set as "individual" instead of "group" (as BlackBoard does not
allow this to be changed later).

Contributions to add more functionality are welcome and encouraged. I hope that
this can become a well known tool among UOIT students and staff to help make
our lives easier.

## How to Use
1. Go to the Releases tab in Github and choose the latest release
2. Download the CRX file and install it in Google Chrome
3. Look at "Things You Can Do"

## Things You Can Do

### Finding out which group a student is in
1. Navigate to the "Groups" page for the relevant courses on BlackBoard
2. Click "Show All" at the bottom of the page
3. Click the BBBS icon (this extension). You will see a log window with a
   selection box, input field, and a "request" button.
4. Select `find-group-links` and click Request. If this worked, you should see
   a bunch of blue-highlighted group ID links show up in the log view.
5. Select `crawl`, type `start` inside the input field, and press `request`.
6. Click any group link to begin the process.
7. Go get some coffee or make yourself a snack. It'll take about a minute and
   you can not switch Google Chrome tabs while it is running (else it will stop).

When you see that Google Chrome is no longer reloading pages, all the group
data has been collected. As long as you don't close Google Chrome, the data
will stay in memory. To figure out what group a student is in, select
`which-group` from the BBBS menu, type a student's name in the input field, and
click request.

Note: if you accidentally stop the scraper, simply click any group link and it
will start again. If it glitches and runs forever, select `crawl` and enter
`stop` as the parameter (this hasn't happened before though).

## For Developers
The code will be commented soon! Probably this weekend.

This extension uses CoffeeScript and JQuery. If you know JavaScript pretty well,
CoffeeScript is very easy to learn (it's a transpiler for JavaScript, like using
LESS or SASS instead of CSS). JQuery is used for scraping, but if you contribute
a scraper you may use whatever you like.

The extension is a bit hacky. Make sure you take a look at the
`Need to Refactor` section to see what you may want to change.

This extension was based on a scraper I made before for a dating website. You
can find that source code at `github.com/KernelDeimos/POF-scraper`.

### Building
Building has only been testing in a Linux environment. If you're using Windows,
look at what `build.sh` is doing and see if you can write a similar script for
PS or CMD.

1. First, install build deps
   ```
   npm install -g coffeescript # sudo if you dare, but this is npm
   ```
2. Run the build script, `./build.sh`
3. If this doesn't work, post an issue and I'll try to help
4. Add to Chrome if you have not already done so. Go to the extensions page, put
   yourself in developer mode, and add the `extension` folder from this repo as
   an extension.

### Architecture
There are four main files:
- `header.coffee` is included in the background script (always running),
    the content script (injected into any BlackBoard page),
    and the popup script (the log window).
- `background.coffee` is the background script. It runs when Chrome starts and
  the same instance keeps running forever. All data that's collected should go
  to the background script.
- `popup.coffee` displays log messages and accepts user input. it can send
  messages to the content script, and it can access global variables of the
  background script under the `bg` identifier.
- `content.coffee` is the content script. It can recieve messages from the
  popup script or the background script. It can send messages to the background
  script. It might be possible to send message from here to the popup, but this
  should be discouraged (messages from the content script should always go
  through the background script first). All scrapers are necessarily implemented
  in the content script.

What happens when the user enters a command in the popup window?
1. The request is sent to the content script first (i.e. to the active page).
2. If the content script defines the selected function, it will perform an
   action and send information to the background script. Any log messages will
   show up in the popup via the background script.
3. If the content script does not define the selected function, it will relay
   the request to the background script.

### Need to Refactor
- `globals.crawling`, defined in `background.coffee`, right now specifically
  refers to crawling group pages. If another crawler is added, perhaps this
  should be changed from a boolean to a value indicating what is being crawled.
