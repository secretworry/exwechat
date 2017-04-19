defmodule WechatBase.Api.Notation.Endpoint do

  alias WechatBase.Api.Notation.Scope
  alias WechatBase.Api.Endpoint

  defmacro path(path) do
  end

  defmacro args([do: block]) do
  end

  defmacro body(handler) do
  end

  defmacro body(type, [do: block]) do
  end

  defmacro response(handler) do
  end

  def build(module) do
    %{attrs: attrs} = Scope.current(module)
    reference = Keyword.get(attrs, :__reference__)
    method = Keyword.get(attrs, :method)
    path = case Keyword.fetch(attrs, :path) do
      {:ok, path} ->
        path
      :error ->
        raise "path is required to define the endpoint #{reference.identifier} at #{reference.location.file}:#{reference.location.line}"
    end
    args = Keyword.get(attrs, :args)
    body_type = Keyword.get(attrs, :body_type)
    response_type = case Keyword.fetch(attrs, :response_type) do
      {:ok, response_type} ->
        response_type
      :error ->
        raise "response is required to define the endpoint #{reference.identifier} at #{reference.location.file}:#{reference.location.line}"
    end
    %Endpoint{method: method, path: path, args: args, body_type: body_type, response_type: response_type}
  end
end