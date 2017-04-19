defmodule WechatBase.Api.Endpoint.DumbBodyType do

  @behaviour WechatBase.Api.Endpoint.BodyType

  alias Maxwell.Conn

  def init(args), do: args

  def embed(conn, {:error, _} = error, body), do: error

  def embed(conn, _args, body), do: {:ok, conn |> Conn.put_req_body(conn, body)}
end