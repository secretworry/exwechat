defmodule WechatBase.Api do

  @type opts :: Map.t
  @type args :: %{required(String.t) => any}
  @type body :: any
  @type invoke_result :: {:ok, any} | {:error, WechatBase.Error.t}

  @callback invoke(api :: String.t, args :: args, opts :: opts) :: invoke_result
  @callback invoke(api :: String.t, args :: args, body :: body, opts :: opts) :: invoke_result
end