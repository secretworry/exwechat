defmodule WechatBase.TmpManager do

  use GenServer

  @max_attempts 10
  @temp_env_vars ~w(TMPDIR TMP TEMP)s
  @table __MODULE__

  def random_directory(prefix, opts \\ []) do
    case ensure_tmp() do
      {:ok, tmp, paths} ->
        open_random_directory(prefix, tmp, paths, opts, 0)
      {:no_tmp, tmps} ->
        {:no_tmp, tmps}
    end
  end

  def random_file(prefix, opts \\ []) do
    case ensure_tmp() do
      {:ok, tmp, paths} ->
        open_random_file(prefix, tmp, paths, opts, 0)
      {:no_tmp, tmps} ->
        {:no_tmp, tmps}
    end
  end

  defp ensure_tmp() do
    pid = self()
    server = server_pid()

    case :ets.lookup(@table, pid) do
      [{^pid, tmp, paths}] ->
        {:ok, tmp, paths}
      [] ->
        {:ok, tmps} = GenServer.call(server, :register)
        {mega, _, _} = :os.timestamp
        subdir = "/yscart-" <> i(mega)

        if tmp = Enum.find_value(tmps, &make_tmp_dir(&1 <> subdir)) do
          true = :ets.insert_new(@table, {pid, tmp, []})
          {:ok, tmp, []}
        else
          {:no_tmp, tmps}
        end
    end
  end

  @compile {:inline, i: 1}
  defp i(integer), do: Integer.to_string(integer)

  defp open_random_directory(prefix, tmp, paths, opts, attempts) when attempts < @max_attempts do
    path = path(prefix, tmp)

    case File.mkdir_p(path) do
      :ok ->
        if Keyword.get(opts, :transient, true) do
          :ets.update_element(@table, self(), {3, [path|paths]})
        end
        {:ok, path}
      {:error, reason} when reason in [:eacces, :enotdir] ->
        open_random_directory(prefix, tmp, paths, opts, attempts + 1)
    end
  end

  defp open_random_file(prefix, tmp, paths, opts, attempts) when attempts < @max_attempts do
    path = path(prefix, tmp)

    case File.write(path, "", [:write, :raw, :exclusive, :binary]) do
      :ok ->
        if Keyword.get(opts, :transient, true) do
          :ets.update_element(@table, self(), {3, [path|paths]})
        end
        {:ok, path}
      {:error, reason} when reason in [:eexist, :eacces] ->
        open_random_file(prefix, tmp, paths, opts, attempts + 1)
    end
  end

  defp open_random_file(_prefix, tmp, _paths, _opts, attempts) do
    {:too_many_attempts, tmp, attempts}
  end

  defp path(prefix, tmp) do
    {_mega, sec, micro} = :os.timestamp
    scheduler_id = :erlang.system_info(:scheduler_id)
    tmp <> "/" <> prefix <> "-" <> i(sec) <> "-" <> i(micro) <> "-" <> i(scheduler_id)
  end

  defp make_tmp_dir(path) do
    case File.mkdir_p(path) do
      :ok -> path
      {:error, _} -> nil
    end
  end

  defp server_pid do
    Process.whereis(__MODULE__) ||
      raise Plug.UploadError, "could not find process #{inspect __MODULE__}. Have you started the #{inspect __MODULE__}?"
  end

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [name: __MODULE__])
  end

  def init(:ok) do
    tmp = Enum.find_value @temp_env_vars, "/tmp", &System.get_env/1
    cwd = Path.join(File.cwd!, "tmp")
    :ets.new(@table, [:named_table, :public, :set])
    {:ok, [tmp, cwd]}
  end

  def handle_call(:register, {pid, _ref}, dirs) do
    Process.monitor(pid)
    {:reply, {:ok, dirs}, dirs}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    case :ets.lookup(@table, pid) do
      [{pid, _tmp, paths}] ->
        :ets.delete(@table, pid)
        Enum.each paths, &File.rm_rf/1
      [] ->
        :ok
    end
    {:noreply, state}
  end

  def handle_info(msg, state) do
    super(msg, state)
  end

end