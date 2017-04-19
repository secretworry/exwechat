defmodule WechatBase.Api.Endpoint.Arg do
  alias __MODULE__

  @type error :: {String.t, Keyword.t}

  defmodule Validator do
    @callback init(args :: any) :: any
    @callback validate(any, any) :: :ok | {:error, {String.t, Keyword.t}}
  end

  @type t :: %__MODULE__{
    name: String.t,
    required?: boolean,
    validator: nil | {Arg.Validator, any}
  }

  @enforce_keys ~w{name}a
  defstruct [:name, required?: false, validator: nil]

  @spec coerce(args :: t, value :: any) :: {:ok, any} | {:error, error}
  def coerce(%{required?: true}, nil), do: {:error, {"can't be blank", []}}
  def coerce(%{validator: nil}, value), do: {:ok, value}
  def coerce(%{validator: {validator, args}}, value) do
    case validator.validate(value, args) do
      :ok ->
        {:ok, value}
      {:error, _} = error ->
        error
    end
  end

end