defmodule WechatBase.Api.Notation.Endpoint.BodyType.EnumHelper do

  @moduledoc false

  def resolve_enum_args([values], args) when is_list(values) do
    resolve_enum_args(values, args)
  end

  def resolve_enum_args(values, args) do
    {type_from_values(values), Map.put(args, :enum, values)}
  end

  defp type_from_values(values) do
    Enum.reduce(values, nil, fn
      integer, nil when is_integer(integer) ->
        :integer
      integer, :integer when is_integer(integer) ->
        :integer
      float, :integer when is_float(float) ->
        :float
      string, nil when is_binary(string) ->
        :string
      string, :string when is_binary(string) ->
        :string
      float, nil when is_float(float) ->
        :float
      float, :float when is_float(float) or is_integer(float) ->
        :float
      value, nil ->
        raise ArgumentError, "Expecting integers, strings or floats but got #{inspect value}"
      _value, _type ->
        raise ArgumentError, "Expecting values of enum to be of the same type, but got #{inspect values}"
    end)
  end
end