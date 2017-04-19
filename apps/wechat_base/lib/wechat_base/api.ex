defmodule WechatBase.Api do

  @type args :: %{required(String.t) => any}
  @type body :: any
  @type invoke_result :: {:ok, any} | {:error, WechatBase.Error.t}

  @callback invoke(api :: String.t, args :: args) :: invoke_result
  @callback invoke(api :: String.t, args :: args, body :: body) :: invoke_result
end