defmodule WechatBase.Api.Endpoint.BodyType.Json do

  alias __MODULE__

  alias WechatBase.Error

  alias Maxwell.Conn

  @behaviour WechatBase.Api.Endpoint.BodyType

  @type opts :: Json.Schema.t

  @spec init(Json.Schema.t) :: opts
  def init(schema) do
    Json.Schema.validate!(schema)
  end


  def embed(conn, body, schema) when is_map(body) do
    with :ok <- validate_body(body, schema) do
      {:ok, do_embed(conn, body)}
    end
  end
  
  def embed(_conn, body, _opts) do
    {:error, Error.new(:illegal_body, "Expect a map as body but got %{body}", %{body: body})}
  end

  defp do_embed(conn, body) do
    conn
    |> Conn.put_req_headers(%{"content-type" => "application/json"})
    |> Conn.put_req_body(Poison.encode!(body))
  end

  defp validate_body(body, schema) do
    Json.Schema.validate_body(schema, body)
  end


end