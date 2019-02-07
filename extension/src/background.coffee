globals =
    debug: []
    students: {}
    groups: {}
    crawling: false

util.source = "B"
util.onLog = (msg)->
    globals.debug.push msg

sendToContentScript = (object)->
    chrome.tabs.query
        active: true
        currentWindow: true
        (tabs)->
            activeTab = tabs[0]
            chrome.tabs.sendMessage activeTab.id,
                object
            return 
    return 

getNextMembers = ()->
    for id of globals.groups
        if !globals.groups[id].checked
            return id
    return false

# Display startup text
globals.introtext = """

.___    _       ____    __  __  _ 
|    \\ | |     /    |  /  ]|  |/ ]
|  o  )| |    (  o  | /  / |  ' / 
|     || |___ |     |/  /  |    \\ 
|  O  ||     ||  _  (   \\_ |     \\
|_____||_____||__|__|\\____||__|\\_|
|    \\  /   \\  /    ||    \\ |   \\  
|  o  )|     |(  o  ||  D  )|    \\ 
|     |(  O  )|     ||    / |  D  |
|  O  ||     ||  _  ||    \\ |     |
|_____| \\___/ |__|__||__|\\_||_____|
        Version 0.0.0 Alpha 
         |  |) /_ '   .-'  
         |  .-.  \`.  `-.  
         |  '--' /.-'    | 
         `------' `-----'  
"""

util.log globals.introtext

util.log "background script started", "info"

chrome.browserAction.onClicked.addListener (tab)->
    chrome.tabs.query
        active: true
        currentWindow: true
        (tabs)->
            activeTab = tabs[0]
            chrome.tabs.sendMessage activeTab.id,
                message: "action_click"
            return 
    return 

# initializeUser = (userID) ->
#     globals.users[userID] =
#         userid: userID
#         checked: false
#         common: []

chrome.extension.onRequest.addListener (request)->
    if request.request == "log"
        globals.debug.push request.message
    else if request.request == "badge"
        globals.score = request.value
        chrome.browserAction.setBadgeText
            text: request.value
    else if request.request == "onload"
        util.log "recieved onload event", "debu"
        if globals.crawling
            sendToContentScript
                command: "find-group-members"
                argument: ""
    else if request.request == "add-group-links"
        util.log "inside add-group-links", "debu"
        for group of request.groups
            if !(group of globals.groups)
                groupO = request.groups[group]
                groupO.checked = false
                globals.groups[group] = groupO
        util.log "current group store contains "+
            Object.keys(globals.groups).length + " items", "debu"
    else if request.request == "add-group-members"
        util.log "inside add-group-members", "debu"
        if !(request.groupID of globals.groups)
            util.log "could not find group for member", "erro"

        globals.groups[request.groupID].members = request.members
        globals.groups[request.groupID].checked  = true

        if globals.crawling
            group = getNextMembers()
            if group != false
                sendToContentScript
                    command: "load-group-page"
                    argument: group
    else if request.request == "which-group"
        personName = request.argument
        util.log "searching groups for "+personName, "debu"
        for group of globals.groups
            for member in globals.groups[group].members
                if (member.trim().indexOf personName.trim()) != -1
                    util.log globals.groups[group].name, "info"
    else if request.request == "crawl"
        if request.argument == "start"
            util.log "CRAWLING"
            globals.crawling = true
        else
            globals.crawling = false
            util.log "NOT CRAWLING"
    return
