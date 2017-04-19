defmodule WechatBase.Error do
  @type t :: {atom, String.t} | {atom, String.t, Map.t}

  @spec new(reason :: atom, message :: String.t) :: t
  @spec new(reason :: atom, message :: String.t, args :: Map.t) :: t
  def new(reason, message, args \\ %{}) do
    {reason, message, args}
  end
end