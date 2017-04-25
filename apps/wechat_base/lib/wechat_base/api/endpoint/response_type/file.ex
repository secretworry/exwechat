defmodule WechatBase.Api.Endpoint.ResponseType.File do
  @behaviour WechatBase.Api.Endpoint.ResponseTyep

  alias WechatBase.TmpManager

  alias WechatBase.Error

  def init(_), do: []

  def parse(conn, _opts) do
    with {:ok, path} <- random_file,
         :ok         <- write_resp_body(conn.resp_body, path),
     do: {:ok, path}
  end

  defp write_resp_body(body, path) when is_binary(body) do
    case File.write(path, body) do
      :ok ->
        :ok
      {:error, error} ->
        {:error, Error.new(:system_error, "Write file to %{path} error", path: path)}
    end
  end

  defp random_file do
    case TmpManager.random_file("response") do
      {:ok, path} ->
        {:ok, path}
      {:notmp, tmps} ->
        {:error, Error.new(:system_error, "Cannot create temp directory")}
      {:too_many_attempts, _} ->
        {:error, Error.new(:system_error, "Create tmp file error: too many attempts")}
    end
  end
end