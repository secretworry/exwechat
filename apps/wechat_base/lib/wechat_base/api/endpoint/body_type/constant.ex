defmodule WechatBase.Api.Endpoint.BodyType.Constant do

  @behaviour WechatBase.Api.Endpoint.BodyType

  def init(constant), do: constant

  def embed(_conn, constant), do: {:ok, constant}

end