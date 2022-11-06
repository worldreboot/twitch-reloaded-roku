sub init()
     m.sideBarButtons = m.top.findNode("sideBarButtons")
     m.sideBarButtons.observeField("itemSelected", "sideBarButtonSelected")
          m.max = 11
end sub

sub onFollowedStreamsChange()
    fs = m.top.followedStreams
    items = fs.Count()
    if items > m.max
         items = m.max
     end if
    counter = 0
    content = createObject("roSGNode", "ContentNode")
     for each stream in m.top.followedStreams
          if counter > m.max
               exit for
          end if
          s = createObject("roSGNode", "ContentNode")
          s.HDPosterUrl = stream.profile_image_url
          s.Title = stream.user_name
          s.ShortDescriptionLine1 = stream.login
          s.ShortDescriptionLine2 = stream.game_id
          content.appendChild(s)
          counter++
    end for
    m.sideBarButtons.content = content
end sub

sub sideBarButtonSelected()
     m.top.streamerSelected = m.sideBarButtons.content.getChild(m.sideBarButtons.itemSelected).ShortDescriptionLine1
end sub