defmodule WechatBase.Api.Notation.Endpoint.BodyType.Form do

  @behaviour WechatBase.Api.Notation.Endpoint.BodyType

  alias WechatBase.Api.Endpoint.BodyType.Form

  import WechatBase.Api.Notation.Endpoint.BodyType.EnumHelper, only: [resolve_enum_args: 2]

  @nodes :__exwechat_body_type_form__

  def eval(env, _args, block) do
    env = decorate_env(env)
    schema = expand(env, block)
    {Form, Form.init(schema)}
  end

  defp decorate_env(env) do
    {env, _} = Code.eval_quoted(quote do
      import unquote(__MODULE__), only: :macros
      __ENV__
    end, [], env)
    env
  end

  defp expand(env, block) do
    Module.put_attribute(env.module, @nodes, [])
    Macro.prewalk(block, fn
      {_, _, _} = node ->
        Macro.expand(node, env)
      node ->
        node
    end)
    nodes = Module.get_attribute(env.module, @nodes) |> Enum.reverse
    Module.delete_attribute(env.module, @nodes)
    nodes
  end

  defmacro field(name, type) do
    record_field(__CALLER__, name, type, [])
  end

  defmacro field(name, type, args) do
    record_field(__CALLER__, name, type, args)
  end

  defp record_field(env, name, type, args) do
    args = Macro.expand(args, env)
    args = Enum.into(args, Map.new)
    {type, type_args} = resolve_type(env, type)
    node = {type, name, Map.merge(args, type_args)}
    put_node(env.module, node)
  end

  defp resolve_type(_env, nil) do
    {:string, %{}}
  end

  defp resolve_type(env, type) do
    {_, {type, args}} = Macro.prewalk(type, {nil, %{}}, fn
      {:required, _, _} = node, {type, opts} ->
        {node, {type, Map.put(opts, :required?, true)}}
      {:enum, _, args}, {_, opts} ->
        {type, opts} = resolve_enum_args(Macro.expand(args, env), opts)
        {nil, {type, opts}}
      type, {_, opts} when type in [:string, :integer, :float, :file, :json]->
        {type, {type, opts}}
      node, acc ->
        {node, acc}
    end)
    {type, args}
  end

  defp put_node(module, node) do
    nodes = Module.get_attribute(module, @nodes)
    Module.put_attribute(module, @nodes, [node | nodes])
  end

end