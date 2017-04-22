defmodule WechatBase.Api.Notation.Endpoint do

  alias WechatBase.Api.Notation.Args
  alias WechatBase.Api.Notation.Scope
  alias WechatBase.Api.Endpoint

  defmacro path(path) do
    record_path(__CALLER__, path)
  end

  defp record_path(env, path) do
    {path, _} = Code.eval_quoted(path, [], env)
    Scope.put_attr(env.module, :path, path)
  end

  defmacro args([do: block]) do
    record_args(__CALLER__, block)
  end

  defp record_args(env, block) do
    args = Args.eval(block, env)
    Scope.put_attr(env.module, :args, args)
  end

  defmacro body(handler) when is_atom(handler) do
    record_body_handler(__CALLER__, handler, nil)
  end

  defmacro body({handler, opts}) do
    record_body_handler(__CALLER__, handler, opts)
  end

  defmacro body(args) do
    %{file: file, line: line} = __CALLER__
    raise ArgumentError, "Expect body(handler) or body({handler, opts}) but got body(#{inspect args}) on #{file}:#{line}"
  end

  defp record_body_handler(env, handler, opts) do
    opts = handler.init(opts)
    Scope.put_attr(env.module, :body_type, {handler, opts})
  end

  defmacro body(type, [do: block]) do
    record_body_block(__CALLER__, type, block)
  end

  defp record_body_block(env, type, block) do
    # TODO
  end

  defmacro response(handler) do
    record_response_handler(__CALLER__, handler)
  end

  defp record_response_handler(env, handler) do
    # TODO
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