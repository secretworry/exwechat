defmodule WechatBase.Api.Model.JsonResponse.Schema do

  @type id_t :: String.t | atom

  @type args_t :: Keyword.t

  @type node_t :: {id_t, args_t, [node_t] | nil}

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
      {name, _, children} = node, acc ->
        value = Maps.get_string_or_atom_field(json, name)
        case convert(children, value, %{}) do
          nil ->
            acc
          not_nil ->
            Map.put(acc, node_name(node), not_nil)
        end
    end)
  end

  def convert(schema, list, base) when is_list(list) do
    Enum.map(list, &convert(schema, &1, base))
  end

  def node_name({id, args, _}) do
    case Keyword.fetch(args, :as) do
      {:ok, name} ->
        name
      :error ->
        id
    end
  end

end
