defmodule WechatBase.Api.Endpoint.BodyType.Arg.Validator.Enum do
  @behaviour WechatBase.Api.Endpoint.BodyType.Arg.Validator

  def init(opts) when is_list(opts) do
    opts
  end

  def init(not_list) do
    raise ArgumentError, "Expect a list, but got #{inspect not_list}"
  end

  def validate(value, enum) do
    if Enum.member?(enum, value) do
      :ok
    else
      {:error, {"should be in %{enum}", %{value: value, enum: enum}}}
    end
  end
end