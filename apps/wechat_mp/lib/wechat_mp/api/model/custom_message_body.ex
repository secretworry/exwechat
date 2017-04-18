defmodule WechatMP.Api.Model.CustomMessageBody do
  @doc """

  ## Text Message
  {
      "touser":"OPENID",
      "msgtype":"text",
      "text":
      {
           "content":"Hello World"
      }
  }

  ## Image Message
  {
      "touser":"OPENID",
      "msgtype":"image",
      "image":
      {
        "media_id":"MEDIA_ID"
      }
  }

  ## Voice Message
  {
    "touser":"OPENID",
    "msgtype":"voice",
    "voice":
    {
      "media_id":"MEDIA_ID"
    }
  }

  ## Video Message
  {
      "touser":"OPENID",
      "msgtype":"video",
      "video":
      {
        "media_id":"MEDIA_ID",
        "thumb_media_id":"MEDIA_ID",
        "title":"TITLE",
        "description":"DESCRIPTION"
      }
  }

  ## Music Message
  {
      "touser":"OPENID",
      "msgtype":"music",
      "music":
      {
        "title":"MUSIC_TITLE",
        "description":"MUSIC_DESCRIPTION",
        "musicurl":"MUSIC_URL",
        "hqmusicurl":"HQ_MUSIC_URL",
        "thumb_media_id":"THUMB_MEDIA_ID"
      }
  }

  ## News Message
  {
      "touser":"OPENID",
      "msgtype":"news",
      "news":{
          "articles": [
           {
               "title":"Happy Day",
               "description":"Is Really A Happy Day",
               "url":"URL",
               "picurl":"PIC_URL"
           },
           {
               "title":"Happy Day",
               "description":"Is Really A Happy Day",
               "url":"URL",
               "picurl":"PIC_URL"
           }
           ]
      }
  }
  {
      "touser":"OPENID",
      "msgtype":"mpnews",
      "mpnews":
      {
           "media_id":"MEDIA_ID"
      }
  }

  ## Card
  {
    "touser":"OPENID",
    "msgtype":"wxcard",
    "wxcard":{
             "card_id":"123dsdajkasd231jhksad"
              },
  }

  ## Custom Service
  {
      "touser":"OPENID",
      "msgtype":"text",
      "text":
      {
           "content":"Hello World"
      },
      "customservice":
      {
           "kf_account": "test1@kftest"
      }
  }
  """

  # TODO implement this
end
