util.source = "C"
util.onLog = (msg)->
    chrome.extension.sendRequest
        request: "log"
        message: msg
    return

util.log "content script loaded", "info"

currentInstance = {}

commands =
    "testthing":
        run: (arg) ->
            console.log arg
    "find-group-links":
        run: (arg) ->
            util.log "inside find-group-links", "debu"
            foundList = {}
            ($ "a").each ()->
                #util.log "found a link", "debu"
                ref = ($ this).attr "href"
                txt = ($ this).text();
                regex = /.*\/viewGroup\?.*group_id=([_0-9]+)/g
                match = regex.exec ref
                if match == null
                    return
                util.log "found group: "+match[1]+": "+txt, "info"
                foundList[match[1]] = {"name": txt};
                return
            chrome.extension.sendRequest
                request: "add-group-links"
                groups: foundList
            return
    "find-group-members":
        run: (arg) ->
            groupID = currentInstance["group"]
            members = []
            ($ ".profileCardAvatarThumb").each () ->
                members.push ($ this).text().trim()
                util.log "found member in "+groupID+": "+($ this).text().trim(), "debu"
            chrome.extension.sendRequest
                request: "add-group-members"
                groupID: groupID
                members: members
            return
    "load-group-page":
        run: (arg) ->
            window.location = "https://uoit.blackboard.com/webapps/blackboard/execute/modulepage/viewGroup?editMode=true&course_id=_39279_1&group_id="+arg

chrome.runtime.onMessage.addListener (request, sender, sendResponse)->
    util.log "want to do '"+request.command+"' with '"+request.argument+"'", "debu"

    # Find command if it is in the content script
    if request.command of commands
        util.log "the command was found in content script", "debu"
        commands[request.command].run(request.argument)
    else
        chrome.extension.sendRequest
            request: request.command
            argument: request.argument
    return

always = () ->
    console.log "always"
    groupR = /.*\/viewGroup\?.*group_id=([_0-9]+)/
    groupM = groupR.exec window.location.href
    groupID = ""
    if groupM != null
        groupID = groupM[1]
    
    currentInstance["group"] = groupID

    $(window).on "load", ()->
        window.setTimeout ()->
            chrome.extension.sendRequest
                request: "onload"
                argument: ""
        , 2000
    # match = regex.exec window.location.href
    # if match != null
    #     score = commands.rateuser.run()
    #     chrome.extension.sendRequest
    #         request: "badge"
    #         value: score.toString()
    # else
    #     chrome.extension.sendRequest
    #         request: "badge"
    #         value: ""

always()
