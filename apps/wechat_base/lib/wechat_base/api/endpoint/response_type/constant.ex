defmodule WechatBase.Api.Endpoint.ResponseType.Constant do
  @behaviour WechatBase.Api.Endpoint.ResponseType

  def init(constant), do: constant

  def parse(_conn, constant), do: {:ok, constant}

end