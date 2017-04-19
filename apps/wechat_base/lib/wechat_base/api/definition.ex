defmodule WechatBase.Api.Definition do

  @type reference :: %{
    module: atom,
    identifier: atom,
    location: %{
      file: String.t,
      line: integer
    }
  }

  @type t :: %__MODULE__{
    identifier: String.t,
    endpoint: WechatBase.Api.Endpoint.t,
    desc: String.t,
    __reference__: nil | reference
  }

  @enforce_keys ~w{identifier endpoint}a
  defstruct [:identifier, :endpoint, desc: "", __reference__: nil]
  
end