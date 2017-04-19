defmodule WechatBase.Api.Endpoint.BodeType do
  @type t :: module

  @type args :: any

  @callback init(args :: any) :: args

  @callback embed(conn :: Maxwell.Conn.t, args :: args, body :: any) :: {:ok, Maxwell.Conn.t} | {:error, WechatBase.Error.t}
end