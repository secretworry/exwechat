defmodule WechatMP.Api.Model.Material do
  @doc """
  ## News type
  {
  "news_item":
  [
      {
      "title":TITLE,
      "thumb_media_id"::THUMB_MEDIA_ID,
      "show_cover_pic":SHOW_COVER_PIC(0/1),
      "author":AUTHOR,
      "digest":DIGEST,
      "content":CONTENT,
      "url":URL,
      "content_source_url":CONTENT_SOURCE_URL
      },
      //多图文消息有多篇文章
   ]
  }

  ## Video type
  {
   "title":TITLE,
   "description":DESCRIPTION,
   "down_url":DOWN_URL,
  }
  ## other type
  file
  """

  @behaviour WechatBase.Api.Model.Response

  # TODO impement this

  def init(_), do: []

  def parse(conn, opts), do: {:ok, conn.resp_body}
end