util =
    name: "BBBS 0.0.0"
    source: "?"
    onLog: (msg)->
    log: (msg, level)->
        fullmsg = msg
        if level != undefined
            fullmsg = "["+level+"] "+msg
            fullmsg = ""+util.source+" "+fullmsg
        console.log "["+util.name+"] "+fullmsg
        util.onLog fullmsg

config = {}
