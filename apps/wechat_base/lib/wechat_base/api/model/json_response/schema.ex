defmodule WechatBase.Api.Model.JSONResponse.Schema do

  @type id_t :: String.t | atom

  @type node_t :: {id_t, [node_t] | nil}

  @type t :: [node_t]

  alias WechatBase.Maps

  def convert([], _json, base) do
    base
  end

  def convert(nil, json, _base) do
    json
  end

  def convert(_schema, nil, base) do
    base
  end

  def convert(schema, json, base) when is_map(json) do
    Enum.reduce(schema, base, fn
      {name, children}, acc ->
        value = Maps.get_string_or_atom_field(json, name)
        case convert(children, value, %{}) do
          nil ->
            acc
          not_nil ->
            Map.put(acc, name, not_nil)
        end
    end)
  end

  def convert(schema, list, base) when is_list(list) do
    Enum.map(list, &convert(schema, &1, base))
  end

end