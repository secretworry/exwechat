defmodule WechatBase.Api.Definition do

  @type t :: %__MODULE__{
    identifier: String.t,
    endpoint: WechatBase.Api.Endpoint.t
  }

  @enforce_keys ~w{identifier endpoint}a
  defstruct [:identifier, :endpoint]
  
end