import strutils

import jester

import router_utils
import ".."/[query, types, api, agents]
import ../views/[general, timeline, list]

template respList*(list, timeline: typed) =
  if list.minId.len == 0:
    halt Http404, showError("List \"" & @"list" & "\" not found", cfg)
  let html = renderList(timeline, list.query, @"name", @"list")
  let rss = "/$1/lists/$2/rss" % [@"name", @"list"]
  resp renderMain(html, request, cfg, rss=rss)

proc createListRouter*(cfg: Config) =
  router list:
    get "/@name/lists/@list":
      cond '.' notin @"name"
      let
        list = await getListTimeline(@"name", @"list", getAgent(), @"max_position")
        tweets = renderTimelineTweets(list, cookiePrefs(), request.path)
      respList list, tweets

    get "/@name/lists/@list/members":
      cond '.' notin @"name"
      let list =
        if @"max_position".len == 0:
          await getListMembers(@"name", @"list", getAgent())
        else:
          await getListMembersSearch(@"name", @"list", getAgent(), @"max_position")

      let users = renderTimelineUsers(list, cookiePrefs(), request.path)
      respList list, users
