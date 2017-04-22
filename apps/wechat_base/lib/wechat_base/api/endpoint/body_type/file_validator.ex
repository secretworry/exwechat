defmodule WechatBase.Api.Endpoint.BodyType.FileValidator do

  @type error :: {String.t, Keyword.t}

  @spec validate(path :: String.t, args :: Map.t) :: {:error, error} | :ok
  def validate(path, args) do
    case File.stat(path) do
      {:ok, stat} ->
        with :ok <- validate_type(path, stat),
             :ok <- validate_readable(path, stat),
         do: do_validate({path, stat}, args)
      {:error, :enoent} ->
        {:error, {"not exist", [path: path]}}
      {:error, :eacces} ->
        {:error, {"cannot access'", [path: path]}}
      {:error, error} ->
        {:error, {"file error", [path: path, error: error]}}
    end
  end

  defp validate_type(path, stat) do
    case stat.type do
      :regular ->
        :ok
      _ ->
        {:error, {"not a file", [path: path]}}
    end
  end

  defp validate_readable(path, stat) do
    case stat.access do
      readable when readable in [:read, :read_write] ->
        :ok
      _ ->
        {:error, {"cannot read", [path: path]}}
    end
  end

  defp do_validate(path_and_stat, args) do
    Enum.reduce_while(args, :ok, fn
      {key, opts}, :ok ->
        case do_validate(path_and_stat, key, opts) do
          :ok -> {:cont, :ok}
          error -> {:halt, {:error, error}}
        end
    end)
  end

  defp do_validate({path, stat}, :limit, size) do
    if stat.size > size do
      {"too big", [size: stat.size, path: path]}
    else
      :ok
    end
  end

  defp do_validate(_, _, _) do
    :ok
  end
end