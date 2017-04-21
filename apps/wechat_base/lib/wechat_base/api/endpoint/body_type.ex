defmodule WechatBase.Api.Endpoint.BodyType do
  @type t :: module

  @type opts :: any

  @callback init(opts :: any) :: opts

  @callback embed(conn :: Maxwell.Conn.t, body :: any, opts :: opts) :: {:ok, Maxwell.Conn.t} | {:error, WechatBase.Error.t}
end