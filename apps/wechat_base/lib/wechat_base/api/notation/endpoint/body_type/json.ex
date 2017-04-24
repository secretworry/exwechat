defmodule WechatBase.Api.Notation.Endpoint.BodyType.Json do

  @behaviour WechatBase.Api.Notation.Endpoint.BodyType

  alias WechatBase.Api.Endpoint.BodyType.Json

  @stack :__exwechat_body_type_json__

  def eval(env, _args, block) do
    env = decorate_env(env)
    schema = eval_block(env, block)
    {Json, Json.init(schema)}
  end

  defp expand(ast, env) do
    Macro.prewalk(ast, fn
      {_, _, _} = node ->
        Macro.expand(node, env)
      node ->
        node
    end)
  end

  defp decorate_env(env) do
    {env, _} = Code.eval_quoted(quote do
      import unquote(__MODULE__), only: :macros
      __ENV__
    end, [], env)
    env
  end

  defmacro field(name, [do: block]) do
    record_field(__CALLER__, name, nil, block)
  end

  defmacro field(name, type) do
    record_field(__CALLER__, name, type, nil)
  end

  defmacro field(name, type, [do: block]) do
    record_field(__CALLER__, name, type, block)
  end

  defp record_field(env, name, type, block) do
    {type, args} = eval_type(env, type, block)
    children = eval_block(env, block)
    put_field(env.module, {type, name, args, children})
  end

  defp eval_type(_env, nil, nil) do
    raise ArgumentError, "type is required for declaring a field"
  end

  defp eval_type(_env, nil, block) when not is_nil(block) do
    {:object, %{}}
  end

  defp eval_type(env, type, nil) do
    do_eval_type(env, type)
  end

  defp eval_type(env, type, block) when not is_nil(block) do
    {type, args} = do_eval_type(env, type)
    case type do
      :object ->
        {type, args}
      {container_type, _} when container_type in [:array, :map] ->
        {type, args}
      type ->
        raise ArgumentError, "Field with block should be either :map, :array or :object but got #{inspect type}"
    end
  end

  defp do_eval_type(env, type) do
    {_, {types, args}} = Macro.prewalk(type, {[], %{}}, fn
      {:required, _, _} = node, {types, opts} ->
        {node, {types, Map.put(opts, :required?, true)}}
      {:enum, _, args}, {types, opts} ->
        {type, opts} = resolve_enum_args(Macro.expand(args, env), opts)
        {nil, {[type | types], opts}}
      {container_type, _, _} = node, {types, opts} when container_type in [:array, :map]->
        {node, {[:array | types], opts}}
      type, {types, opts} when type in [:string, :integer, :float, :object]->
        {type, {[type | types], opts}}
      container_type, {types, opts} when container_type in [:arrya, :map] ->
        {container_type, {[container_type | types], opts}}
      node, acc ->
        {node, acc}
    end)
    if types == [] do
      raise ArgumentError, "Illegal type declaration, cannot find type in #{Macro.to_string(type)}"
    else
      {compose_types(types), args}
    end
  end

  defp compose_types(types) do
    Enum.reduce(types, nil, fn
      primary_type, nil when primary_type in [:string, :integer, :float, :object] ->
        primary_type
      container_type, nil when container_type in [:array, :map]->
        {container_type, :object}
      container_type, subtype when not is_nil(subtype) when container_type in [:array, :map] ->
        {container_type, subtype}
      type, subtype when not is_nil(subtype) ->
        raise ArgumentError, "#{type} is not a container type"
    end)
  end

  defp resolve_enum_args([values], args) when is_list(values) do
    resolve_enum_args(values, args)
  end

  defp resolve_enum_args(values, args) do
    {type_from_values(values), Map.put(args, :enum, values)}
  end

  defp type_from_values(values) do
    Enum.reduce(values, nil, fn
      integer, nil when is_integer(integer) ->
        :integer
      integer, :integer when is_integer(integer) ->
        :integer
      float, :integer when is_float(float) ->
        :float
      string, nil when is_binary(string) ->
        :string
      string, :string when is_binary(string) ->
        :string
      float, nil when is_float(float) ->
        :float
      float, :float when is_float(float) or is_integer(float) ->
        :float
      value, nil ->
        raise ArgumentError, "Expecting integers, strings or floats but got #{inspect value}"
      value, type ->
        raise ArgumentError, "Expecting values of enum to be of the same type, but got #{inspect values}"
    end)
  end

  defp eval_block(env, block) do
    open_scope(env.module)
    expand(block, env)
    close_scope(env.module) |> Enum.reverse
  end

  defp scope(module) do
    case Module.get_attribute(module, @stack) do
      nil ->
        Module.put_attribute(module, @stack, [])
        []
      value ->
        value
    end
  end

  defp open_scope(module) do
    Module.put_attribute(module, @stack, [[] | scope(module)])
  end

  defp close_scope(module) do
    {current, rest} = split_scope(module)
    Module.put_attribute(module, @stack, rest)
    current
  end

  defp put_field(module, field) do
    {current, rest} = split_scope(module)
    Module.put_attribute(module, @stack, [[field | current] | rest])
  end

  defp split_scope(module) do
    case scope(module) do
      [] -> {nil, []}
      [current | rest] -> {current, rest}
    end
  end

end