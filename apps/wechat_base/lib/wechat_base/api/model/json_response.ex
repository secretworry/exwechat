defmodule WechatBase.Api.Model.JsonResponse do

  alias WechatBase.Api.Model.JsonResponse.Schema

  defmacro __using__(_args) do
    quote do
      @behaviour WechatBase.Api.Endpoint.ResponseType

      import unquote(__MODULE__), only: :macros

      @before_compile unquote(__MODULE__)

      def init(_), do: []

    end
  end

  defmacro model([do: block]) do
    eval_model(__CALLER__, block)
  end

  defmodule Builder do

    @stack :__exwechat_json_response__

    defmacro field(name) do
      record_field(__CALLER__, name, [], nil)
    end

    defmacro field(name, [do: block]) do
      record_field(__CALLER__, name, [], block)
    end

    defmacro field(name, args) do
      record_field(__CALLER__, name, args, nil)
    end

    defmacro field(name, args, [do: block]) do
      record_field(__CALLER__, name, Macro.expand(args, __CALLER__), block)
    end

    defmacro array(name) do
      record_field(__CALLER__, name, [], nil)
    end

    defmacro array(name, [do: block]) do
      record_field(__CALLER__, name, [], block)
    end
    defmacro array(name, args, [do: block]) do
      record_field(__CALLER__, name, Macro.expand(args, __CALLER__), block)
    end

    defmacro array(name, args) do
      record_field(__CALLER__, name, args, nil)
    end

    defp record_field(env, name, args, block) do
      children = expand_block(env, block)
      put_record(env.module, {name, args, children})
    end

    def expand_block(_env, nil), do: nil

    def expand_block(env, block) do
      open_scope(env.module)
      block |> expand(env)
      close_scope(env.module) |> Enum.reverse
    end

    defp expand(block, env) do
      Macro.prewalk(block, fn
        {_, _, _} = node ->
          Macro.expand(node, env)
        node ->
          node
      end)
    end

    defp put_record(module, record) do
      update_current(module, fn
        nil ->
          nil
        records ->
          [record | records]
      end)
    end

    def on(module) do
      case Module.get_attribute(module, @stack) do
        nil ->
          Module.put_attribute(module, @stack, [])
          []
        scope ->
          scope
      end
    end

    def open_scope(module) do
      scope = on(module)
      Module.put_attribute(module, @stack, [[] | scope])
    end

    def close_scope(module) do
      {current, tail} = split(module)
      Module.put_attribute(module, @stack, tail)
      current
    end

    defp split(module) do
      case on(module) do
        [] ->
          {nil, []}
        [head|tail] ->
          {head, tail}
      end
    end

    defp update_current(module, updater) do
      {current, tail} = split(module)
      Module.put_attribute(module, @stack, [updater.(current) | tail])
    end
  end

  @schema :__exwechat_json_response_schema__

  defmacro __before_compile__(env) do
    schema = Module.get_attribute(env.module, @schema) || []
    fields = Enum.map(schema, fn
      node ->
        {Schema.node_name(node), nil}
    end) ++ [{:__origin__, nil}]
    code = quote do
      def __schema__(), do: unquote(schema |> Macro.escape)

      defstruct unquote(fields)

      def parse(conn, _) do
        schema = __schema__()
        {:ok, WechatBase.Api.Model.JsonResponse.Schema.convert(schema, conn.resp_body, %__MODULE__{__origin__: conn.resp_body})}
      end
    end
    code
  end

  defp eval_model(env, block) do
    env = decorate_env(env)
    schema = Builder.expand_block(env, block)
    Module.put_attribute(env.module, @schema, schema)
  end

  defp decorate_env(env) do
    {env, _} = Code.eval_quoted(quote do
      import unquote(Module.concat([__MODULE__, "Builder"])), only: :macros
      __ENV__
    end, [], env)
    env
  end


end
