defmodule WechatBase.Api.Endpoint.BodyType.File do
  @behaviour WechatBase.Api.Endpoint.BodyType

  alias WechatBase.Error
  alias WechatBase.Api.Endpoint.BodyType.FileValidator
  alias Maxwell.Conn

  def init(nil), do: %{}

  def init(opts) when is_map(opts), do: opts

  def embed(conn, path, opts) when is_binary(path) do
    case FileValidator.validate(path, opts) do
      :ok ->
        {:ok, do_embed(conn, path)}
      {:error, error} ->
        {:error, Error.new(:illegal_body, "Validate body %{body} error: %{error}", %{body: path, errors: [{"", error}]})}
    end
  end

  defp do_embed(conn, path) do
    conn
    |> Conn.put_req_body({:file, path})
  end

  def embed(conn, not_path, opts) do
    {:error, Error.new(:illegal_body, "Expecting a path as body but got %{body}", %{body: not_path})}
  end
end