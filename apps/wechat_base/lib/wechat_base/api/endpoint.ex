defmodule WechatBase.Api.Endpoint do

  alias __MODULE__

  alias Maxwell.Conn
  alias WechatBase.Client
  alias WechatBase.Error
  alias WechatBase.Maps

  @type t :: %__MODULE__{
    method: :get | :post,
    path: String.t,
    args: [Endpoin.Arg.t],
    body_type: nil | {EndPoint.BodyType.t, any},
    response_type: {EndPoint.ResponseType.t, any}
  }

  @type options :: Map.t

  @enforce_keys ~w{method path}a
  defstruct [:method, :path, args: %{}, body_type: nil, response_type: nil]

  @type call_result_t :: {:ok, any} | {:error, Error.t}


  @spec call(endpoint :: t, base_uri :: String.t, args :: Map.t, body :: any) :: call_result_t
  @spec call(endpoint :: t, base_uri :: String.t, args :: Map.t, body :: any, options :: options) :: call_result_t
  def call(endpoint, base_uri, args, body, options \\ %{}) do
    conn = Conn.new(base_uri)
    with {:ok, conn} <- embed_args(conn, endpoint, args),
         {:ok, conn} <- maybe_embed_body(conn, endpoint, body),
         {:ok, conn} <- send_request(conn, endpoint, options),
     do: process_response(conn, endpoint)
  end

  defp embed_args(conn, %{args: args_spec}, args) do
    {params, errors} = Enum.reduce(args_spec, {Map.new, []}, fn
      arg, {params, errors} ->
        case Endpoint.Arg.coerce(arg, Maps.get_string_or_atom_field(args, arg.name)) do
          {:ok, value} ->
            {Map.put(params, arg.name, value), errors}
          {:error, error} ->
            {params, [{arg.name, error} | errors]}
        end
    end)
    if Enum.empty?(errors) do
      {:ok, do_embed_args(conn, params)}
    else
      {:error, Error.new(:illegal_args, "Illegal args", %{errors: errors})}
    end
  end

  defp do_embed_args(conn, args) do
    query = Enum.map(args, fn
      {key, value} when is_map(value) or is_list(value) ->
        {key, Poison.encode!(value)}
      {key, value} ->
        {key, value}
    end) |> Enum.into(%{})
    conn |> Conn.put_query_string(query)
  end

  defp maybe_embed_body(conn, %{method: :get}, _body), do: {:ok, conn}

  defp maybe_embed_body(conn, endpoint, body), do: do_embed_body(conn, endpoint, body)

  defp do_embed_body(conn, %{body_type: nil}, body) do
    conn = conn
    |> Conn.put_req_headers(%{"content-type" => "text/plain"})
    |> Conn.put_req_body(body)
    {:ok, conn}
  end

  defp do_embed_body(conn, %{body_type: {body_type, opts}}, body) do
    body_type.embed(conn, body, opts)
  end

  defp do_request(method, conn) do
    case method do
      :get ->
        conn |> Client.get
      :post ->
        conn |> Client.post
      _ ->
        raise "Illegal request method #{inspect method}"
    end
  end

  defp send_request(conn, %{method: method}, options) do
    request_call = Map.get(options, :request_call, &do_request/2)
    request_call.(method, conn)
    |> handle_request_result
  end

  defp handle_request_result({:ok, _} = ok), do: ok
  defp handle_request_result({:error, reason, conn}) do
    {:error, Error.new(:request_error, "Send request error", %{conn: conn, reason: reason})}
  end

  defp process_response(conn, endpoint) do
    case conn |> Conn.get_resp_header("content-type") do
      nil ->
        {:error, Error.new(:no_content_type, "No Content-Type is returned", %{conn: conn})}
      content_type ->
        case WechatBase.Conn.Utils.media_type(content_type) do
          {:ok, "application", "json", _params} ->
            process_json_response(conn, endpoint)
          {:ok, _type, _subtype, _params} ->
            process_other_response(conn, endpoint)
          :error ->
            {:error, Error.new(:illegal_content_type, "Illegal Content-Type %{content_type}", %{content_type: content_type})}
        end
    end
  end

  defp process_json_response(conn, endpoint) do
    body = Conn.get_resp_body(conn)
    case Poison.decode(body) do
      {:ok, json} ->
        conn = %{conn | resp_body: json}
        do_process_json_response(conn, endpoint)
      {:error, _} ->
        {:error, Error.new(:illegal_json, "Illegal Json response %{content}", %{content: body})}
    end
  end

  defp do_process_json_response(%{resp_body: %{"errcode" => errcode} = json}, _endpoint) when errcode > 0 do
    {:error, Error.new(:wechat_error, "Wechat Error(%{errcode}): %{errmsg}", %{errcode: json["errcode"], errmsg: json["errmsg"]})}
  end

  defp do_process_json_response(conn, %{response_type: {response_type, args}}) do
    response_type.parse(conn, args)
  end

  defp process_other_response(conn, %{response_type: {response_type, args}}) do
    response_type.parse(conn, args)
  end
end
