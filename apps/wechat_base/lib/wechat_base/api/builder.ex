defmodule WechatBase.Api.Builder do

  alias WechatBase.Api.Notation

  @reflection :__exwechat_endpoint__

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__), only: :macros

      @before_compile unquote(__MODULE__)

      @behaviour WechatBase.Api

      def invoke(api, args, body \\ nil, opts) do
        endpoint = unquote(@reflection)(api)
        uri = uri_from_opts(opts)
        WechatBase.Api.Endpoint.call(endpoint, uri, args, body, opts)
      end

      defp uri_from_opts(%{uri: uri}) do
        uri
      end

      defp uri_from_opts(%{host: host}) do
        "https://#{host}/"
      end

      defp uri_from_opts(_) do
        raise ArgumentError, "Illegal opts, either uri or host is required"
      end
    end
  end

  defmacro namespace(name \\ nil, raw_attrs \\ [], [do: block]) do
    record_namespace(__CALLER__, name, raw_attrs, block)
  end

  defp record_namespace(env, name, raw_attrs, block) do
    Notation.scope(env, :namespace, name, raw_attrs, block)
  end

  defmacro get(name \\ nil, raw_attrs \\ [], [do: block]) do
    raw_attrs = raw_attrs
    |> Keyword.put(:method, :get)
    record_endpoint(__CALLER__, name, raw_attrs, block)
  end

  defmacro post(name \\ nil, raw_attrs \\ [], [do: block]) do
    raw_attrs = raw_attrs
    |> Keyword.put(:method, :post)
    record_endpoint(__CALLER__, name, raw_attrs, block)
  end

  defp record_endpoint(env, name, raw_attrs, block) do
    Notation.scope(env, :endpoint, name, raw_attrs, block)
  end

  defmacro __before_compile__(env) do
    definitions = Notation.get_definitions(env.module)
    Enum.map(definitions, &define_endpoint/1) ++ [quote do
      def unquote(@reflection)(api), do: raise(ArgumentError, "Undefined api #{api}")
    end]
  end

  defp define_endpoint(definition) do
    %{identifier: identifier, endpoint: endpoint} = definition
    quote do
      def unquote(@reflection)(unquote(identifier)), do: unquote(endpoint |> Macro.escape)
    end
  end
end