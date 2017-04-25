defmodule WechatMP.Api.Model.Media do

  @behaviour WechatBase.Api.Model.Response

  # TODO impement this

  def init(_), do: []

  def parse(conn, opts), do: {:ok, conn.resp_body}
end