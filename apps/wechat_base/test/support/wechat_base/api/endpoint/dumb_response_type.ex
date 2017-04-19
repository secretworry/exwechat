defmodule WechatBase.Api.Endpoint.DumbResponseType do
  @behaviour WechatBase.Api.Endpoint.ResponseType

  def init(args), do: args

  def parse(conn, {:error, _} = error), do: error
  def parse(conn, _args), do: {:ok, Maxwell.Conn.get_resp_body(conn)}

end