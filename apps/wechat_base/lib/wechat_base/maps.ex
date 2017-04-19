defmodule WechatBase.Maps do

  @spec get_string_or_atom_field(Map.t, atom | String.t ) :: any | nil
  def get_string_or_atom_field(map, field) when is_atom(field) do
    case Map.fetch(map, Atom.to_string(field)) do
      {:ok, value} ->
        value
      :error ->
        Map.get(map, field)
    end
  end
  def get_string_or_atom_field(map, field) when is_binary(field) do
    case Map.fetch(map, field) do
      {:ok, value} ->
        value
      :error ->
        try do
          atom_key = String.to_existing_atom(field)
          Map.get(map, atom_key)
        rescue
          ArgumentError ->
            nil
        end
    end
  end

end