defmodule WechatBase.Api.Notation.Endpoint do

  alias WechatBase.Api.Notation.Endpoint.Args
  alias WechatBase.Api.Notation.Scope
  alias WechatBase.Api.Endpoint

  alias WechatBase.Api.Notation.Endpoint.BodyType.{Json, Form}
  alias WechatBase.Api.Notation.Endpoint.ResponseType.{Constant, File}

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

  defmacro body(handler) do
    record_body_handler(__CALLER__, Macro.expand(handler, __CALLER__), nil)
  end

  defmacro body(type, [do: block]) do
    record_body_block(__CALLER__, type, [], block)
  end

  defmacro body(handler, opts) do
    record_body_handler(__CALLER__, Macro.expand(handler, __CALLER__), Macro.expand(opts, __CALLER__))
  end

  defp record_body_handler(env, handler, opts) when is_atom(handler) do
    case Atom.to_char_list(handler) do
      'Elixir.' ++ _ ->
        opts = handler.init(opts)
        {handler, opts}
      _is_atom ->
        case handler do
          :json ->
            Json.eval(env, [], nil)
          :form ->
            Form.eval(env, [], nil)
          :file ->
            {WechatBase.Api.Endpoint.BodyType.File, WechatBase.Api.Endpoint.BodyType.File.init(nil)}
          illegal_type ->
            raise ArgumentError, "Unrecognizable body type #{inspect illegal_type}"
        end
    end
    Scope.put_attr(env.module, :body_type, {handler, opts})
  end

  defp record_body_block(env, type, args, block) do
    {handler, opts} = case type do
      :json ->
        Json.eval(env, args, block)
      :form ->
        Form.eval(env, args, block)
      :file ->
        {WechatBase.Api.Endpoint.BodyType.File, WechatBase.Api.Endpoint.BodyType.File.init(nil)}
      illegal_type ->
        raise ArgumentError, "Unrecognizable body type #{inspect illegal_type}"
    end
    record_body_handler(env, handler, opts)
  end

  defmacro response(handler_or_value) do
    record_response_handler(__CALLER__, Macro.expand(handler_or_value, __CALLER__), [])
  end

  defp record_response_handler(env, handler, args) when is_atom(handler) do
    response_type = case Atom.to_char_list(handler) do
      'Elixir.' ++ _ ->
        opts = handler.init(args)
        {handler, opts}
      _is_atom ->
        case handler do
          :ok ->
            {Constant, :ok}
          :file ->
            {File, []}
          atom ->
            raise ArgumentError, "Cannot recognize response type #{inspect atom}"
        end
    end
    Scope.put_attr(env.module, :response_type, response_type)
  end

  defp record_response_handler(env, value, _args) do
    raise ArgumentError, "Cannot recognize response type #{inspect value}"
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