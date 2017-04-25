defmodule WechatMP.Api.Model.MassiveMessageBody do
  @doc """
  # Tag
  {
     "filter":{
        "is_to_all":false,
        "tag_id":2
     },
     "mpnews":{
        "media_id":"123dsdajkasd231jhksad"
     },
      "msgtype":"mpnews",
      "send_ignore_reprint":0
  }
  {
     "filter":{
        "is_to_all":false,
        "tag_id":2
     },
     "text":{
        "content":"CONTENT"
     },
      "msgtype":"text"
  }
  {
     "filter":{
        "is_to_all":false,
        "tag_id":2
     },
     "voice":{
        "media_id":"123dsdajkasd231jhksad"
     },
      "msgtype":"voice"
  }
  {
     "filter":{
        "is_to_all":false,
        "tag_id":2
     },
     "image":{
        "media_id":"123dsdajkasd231jhksad"
     },
      "msgtype":"image"
  }
  {
     "filter":{
        "is_to_all":false,
        "tag_id":2
     },
     "mpvideo":{
        "media_id":"IhdaAQXuvJtGzwwc0abfXnzeezfO0NgPK6AQYShD8RQYMTtfzbLdBIQkQziv2XJc"
     },
      "msgtype":"mpvideo"
  }
  {
     "filter":{
        "is_to_all":false,
        "tag_id":"2"
     },
    "wxcard":{
             "card_id":"123dsdajkasd231jhksad"
              },
     "msgtype":"wxcard"
  }
  """
  # TODO implement this

  def init(_), do: []

  def embed(conn, body, opts) do
    {:ok, conn}
  end

end
