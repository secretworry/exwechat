defmodule WechatBase.Api.Endpoint.ResponseType do
  @type t :: module

  @type opts_t :: any

  @callback init(args :: any) :: opts_t

  @callback parse(conn :: Maxwell.Conn.t, opts :: opts_t) :: {:ok, any} | {:error, WechatBase.Error.t}
end