' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of detailsScreen
function Init()
    ' observe "visible" so we can know when DetailsScreen change visibility
    m.top.ObserveField("visible", "OnVisibleChange")
    ' observe "itemFocused" so we can know when another item gets in focus
    m.top.ObserveField("itemFocused", "OnItemFocusedChanged")
    ' save a references to the DetailsScreen child components in the m variable
    ' so we can access them easily from other functions
    m.buttons = m.top.FindNode("buttons")
    m.poster = m.top.FindNode("poster")
    m.description = m.top.FindNode("descriptionLabel")
    m.timeLabel = m.top.FindNode("timeLabel")
    m.titleLabel = m.top.FindNode("titleLabel")
    m.releaseLabel = m.top.FindNode("releaseLabel")
    ' create buttons
end function

sub onVisibleChange()' invoked when DetailsScreen visibility is changed
    ' set focus for buttons list when DetailsScreen becomes visible
    if m.top.visible = true
        m.buttons.SetFocus(true)
    end if
end sub

sub SetButtons(buttons as Object)
    result = []
    ' prepare array with button's titles
    for each button in buttons
        result.push({title : button, id: LCase(button)})
    end for
    m.buttons.content = ContentListToSimpleNode(result) ' populate buttons list
end sub

sub OnContentChange(event as Object)
    content = event.getData()
    if content <> invalid
        m.isContentList = content.GetChildCount() > 0
        if m.isContentList = false
            SetDetailsContent(content)
            m.buttons.SetFocus(true)
        end if
    end if
end sub

sub SetDetailsContent(content as Object)
    ' populate screen components with metadata
    m.description.text = content.description
    m.poster.uri = content.hdPosterUrl
    if content.length <> invalid and content.length <> 0
        m.timeLabel.text = getTime(content.length)
    end if
    m.titleLabel.text = content.title
    m.releaseLabel.text = Left(content.releaseDate, 10)
    buttonList = ["Play"]
    if content.mediaType = "series"
        smartBookmarks = MasterChannelSmartBookmarks()
        ' episodeId contains id of the episode which should be played
        episodeId = smartBookmarks.GetSmartBookmarkForSeries(content.id)
        if episodeId <> invalid and episodeId <> ""
            episode = FindNodeById(content, episodeId)
            if episode <> invalid
                episode.bookmarkPosition = MasterChannelBookmarks().GetBookmarkForVideo(episode)
                buttonList.Push("Continue")
            end if
        end if

        buttonList.Push("See all episodes")
    else
        ' set playback start position using bookmarks
        content.bookmarkPosition = MasterChannelBookmarks().GetBookmarkForVideo(content)
        ' Add Continue button if user started this content but didn't finish it
        if content.bookmarkPosition > 0
            buttonList.Push("Continue")
        end if
    end if
    SetButtons(buttonList)
end sub

sub OnJumpToItem() ' invoked when jumpToItem field is populated
    content = m.top.content
    ' check if jumpToItem field has valid value
    ' it should be set within interval from 0 to content.Getchildcount()
    if content <> invalid and m.top.jumpToItem >= 0 and content.GetChildCount() > m.top.jumpToItem
        m.top.itemFocused = m.top.jumpToItem
    end if
end sub

sub OnItemFocusedChanged(event as Object)' invoked when another item is focused
    focusedItem = event.GetData() ' get position of focused item
    if m.top.content.GetChildCount() > 0
        content = m.top.content.GetChild(focusedItem) ' get metadata of focused item
        SetDetailsContent(content) ' populate DetailsScreen with item metadata
    end if 
end sub

' The OnKeyEvent() function receives remote control key events
function OnkeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        currentItem = m.top.itemFocused ' position of currently focused item
        ' handle "left" button keypress
        if key = "left" and m.isContentList = true
            ' navigate to the left item in case of "left" keypress
            m.top.jumpToItem = currentItem - 1
            result = true
        ' handle "right" button keypress
        else if key = "right" and m.isContentList = true
            ' navigate to the right item in case of "right" keypress
            m.top.jumpToItem = currentItem + 1
            result = true
        end if
    end if
    return result
end function