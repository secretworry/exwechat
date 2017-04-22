defmodule WechatBase.Api.Endpoint.BodyType.Form do
  @behaviour WechatBase.Api.Endpoint.BodyType

  alias __MODULE__

  alias Maxwell.Conn
  alias WechatBase.Maps
  alias WechatBase.Error

  def init(schema) do
    Form.Schema.validate!(schema)
  end

  def embed(conn, body, schema) when is_map(body) do
    with :ok <- Form.Schema.validate_body(schema, body) do
      {:ok, do_embed(conn, body, schema)}
    end
  end

  def embed(_conn, not_map, _schema) do
    {:error, Error.new(:illegal_body, "Expecting a map as body but got %{body}", %{body: not_map})}
  end

  defp do_embed(conn, body, schema) when is_map(body) and is_list(schema) do
    parts = Enum.reduce(schema, [], fn
      {type, name, _}, parts->
        do_embed_field(type, to_string(name), Maps.get_string_or_atom_field(body, name), parts)
    end) |> Enum.reverse
    conn
    |> Conn.put_req_body({:multipart, parts})
  end

  defp do_embed_field(_type, _name, nil, parts) do
    parts
  end

  defp do_embed_field(:file, name, path, parts) do
    filename = Path.basename(path)
    disposition = {"form-data", [{"name", name}, {"filename", filename}]}
    [{:file, path, disposition, []} | parts]
  end

  defp do_embed_field(primary_type, name, value, parts) when primary_type in [:string, :integer, :float] do
    [{name, value} | parts]
  end
end