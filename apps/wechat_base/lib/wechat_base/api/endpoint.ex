defmodule WechatBase.Api.Endpoint do

  import __MODULE__

  @type t :: %__MODULE__{
    method: "get" | "post",
    path: String.t,
    args: %{required(String.t) => Endpoin.Arg.t},
    body_type: nil | EndPoint.BodyType.t,
    authorized?: bool,
    response_type: EndPoint.ResponseTpye.t
  }

  @enforce_keys ~w{method path}a
  defstruct [:method, :path, args: %{}, body_type: nil, authorized?: true, response_type: null]

  defprotocol Arg do
    @type t :: module
  end

  defprotocol BodyType do
    @type t :: module
  end

  defprotocol ResponseType do
    @type t :: module
  end
end