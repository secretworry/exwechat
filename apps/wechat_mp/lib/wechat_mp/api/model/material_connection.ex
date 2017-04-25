defmodule WechatMP.Api.Model.MaterialConnection do

  @doc """
    ## News type
    {
      "total_count": TOTAL_COUNT,
      "item_count": ITEM_COUNT,
      "item": [{
          "media_id": MEDIA_ID,
          "content": {
              "news_item": [{
                  "title": TITLE,
                  "thumb_media_id": THUMB_MEDIA_ID,
                  "show_cover_pic": SHOW_COVER_PIC(0 / 1),
                  "author": AUTHOR,
                  "digest": DIGEST,
                  "content": CONTENT,
                  "url": URL,
                  "content_source_url": CONTETN_SOURCE_URL
              },
              //多图文消息会在此处有多篇文章
              ]
           },
           "update_time": UPDATE_TIME
       },
       //可能有多个图文消息item结构
     ]
    }

    ## other type
    {
      "total_count": TOTAL_COUNT,
      "item_count": ITEM_COUNT,
      "item": [{
          "media_id": MEDIA_ID,
          "name": NAME,
          "update_time": UPDATE_TIME,
          "url":URL
      },
      //可能会有多个素材
      ]
    }
  """

  @behaviour WechatBase.Api.Model.Response

  # TODO impement this

  def init(_), do: []

  def parse(conn, opts), do: {:ok, conn.resp_body}
end