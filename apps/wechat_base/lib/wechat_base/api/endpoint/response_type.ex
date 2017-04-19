defmodule WechatBase.Api.Endpoint.ResponseType do
  @type t :: module

  @type args :: any

  @callback init(args :: any) :: args

  @callback parse(conn :: Maxwell.Conn.t, args :: args) :: {:ok, any} | {:error, WechatBase.Error.t}
end