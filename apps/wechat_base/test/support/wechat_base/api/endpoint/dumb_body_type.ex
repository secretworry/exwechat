defmodule WechatBase.Api.Endpoint.DumbBodyType do

  @behaviour WechatBase.Api.Endpoint.BodyType

  alias Maxwell.Conn

  def init(opts), do: opts

  def embed(conn, body, {:error, _} = error), do: error

  def embed(conn, body, opts), do: {:ok, conn |> Conn.put_req_body(body)}
end