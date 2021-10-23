' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub ShowVideoScreen(rowContent as Object, selectedItem = 0 as Integer, isSeries = false as Boolean)
    m.videoScreen = CreateObject("roSGNode", "VideoScreen") ' create an instance of videoScreen
    m.videoScreen.observeField("close", "OnVideoScreenClose")
    ' populate videoScreen data
    m.videoScreen.isSeries = isSeries
    m.videoScreen.content = rowContent
    m.videoScreen.startIndex = selectedItem
    ' append videoScreen to scene and show it
    ShowScreen(m.videoScreen)
end sub

sub OnVideoScreenClose(event as Object) ' invoked once videoScreen's close field is changed
    m.videoScreen = event.GetRoSGNode()
    close = event.GetData()
    if close = true
        CloseScreen(m.videoScreen) ' remove videoScreen from scene and close it
        screen = GetCurrentScreen()
        screen.SetFocus(true) ' return focus to DetailsScreen
        if m.deepLinkDetailsScreen <> invalid
            content = m.videoScreen.content
            if m.videoScreen.isSeries = true
                content = content.GetChild(m.videoScreen.lastIndex)
            end if
            if content <> invalid
                m.deepLinkDetailsScreen.content = content.clone(true)
            end if
        else
            ' in case of series we shouldn't change focus on DetailsScreen
            if m.videoScreen.isSeries = false
                screen.jumpToItem = m.videoScreen.lastIndex
            end if
        end if
    end if
end sub

' Callback function when the channel is suspended from a channel exit. In this example, the channel will check
' whether the exit was due to a home button press. If so, if the user was in the middle of playback, they will
' be taken back to the details screen of that content when the user relaunches the channel. All other exit
' reasons will take the user back to where they previously left off.
sub onMainSceneSuspend(args as dynamic)
    print "***** Suspending Channel *****"
    print "Args passed into suspend callback: "; args
    if args.doesExist("lastSuspendOrResumeReason") and args.lastSuspendOrResumeReason = "home"
        if m.videoScreen <> invalid
            playerTask = m.videoScreen.findNode("PlayerTask")
            playerTask.control = "STOP"
        end if
    end if
end sub

' Callback function when the channel resumes after a channel exit. In this example, the channel will check if
' there were any launch parameters passed with deeplink information. If so, the channel will deeplink into the
' appropriate content using the behavior defined by the media type.
sub onMainSceneResume(args as dynamic)
    print "***** Resuming Channel *****"
    print "Args passed into resume callback: "; args
    if args.doesExist("launchParams")
        if args.launchParams.contentId <> invalid and args.launchParams.mediaType <> invalid
            DeepLink(m.contentTask.content, args.launchParams.mediaType, args.launchParams.contentId)
        end if
    end if
    myScene = m.top.getScene()
    myScene.signalBeacon("AppResumeComplete")
end sub
