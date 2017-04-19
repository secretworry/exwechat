defmodule WechatBaes.Api.Builder do

  alias WechatBase.Api.Notation

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__), only: :macros

      @behaviour WechatBase.Api

    end
  end

  defmacro namespace(name \\ nil, raw_attrs \\ [], [do: block]) do
    record_namespace(__CALLER__, name, raw_attrs, block)
  end

  defp record_namespace(env, name, raw_attrs, block) do
    Notation.scope(env, :namespace, name, raw_attrs, block)
  end

  defmacro get(name \\ nil, raw_attrs \\ [], [do: block]) do
    raw_attrs
    |> Keyword.put(:method, :get)
    record_endpoint(__CALLER__, name, raw_attrs, block)
  end

  defmacro post(name \\ nil, raw_attrs \\ [], [do: block]) do
    raw_attrs
    |> Keyword.put(:method, :post)
    record_endpoint(__CALLER__, name, raw_attrs, block)
  end

  defp record_endpoint(env, name, raw_attrs, block) do
    Notation.scope(env, :endpoint, name, raw_attrs, block)
  end

end