defmodule WechatBase.Api.Notation do

  alias WechatBase.Api.Definition

  @doc false
  def scope(env, kind, identifier, attrs, block) do
    open_scope(kind, env, identifier, attrs)
    env = decorate_env(kind, env)

    block |> expand(env)

    close_scope(kind, env, identifier)

    Scope.recorded!(env.module, kind, identifier)
  end

  defp expand(ast, env) do
    Macro.prewalk(ast, fn
      {:@, _, [{:desc, _, [desc]}]} ->
        Module.put_attribute(env.module, :__wechatex_desc__, desc)
      {_, _, _} = node -> Macro.expand(node, env)
        node -> node
    end)
  end

  defp open_scope(kind, env, identifier, attrs) do
    attrs = attrs
    |> Keyword.put(:identifier, identifier)
    |> add_reference(env, identifier)
    |> add_description(env)

    Scope.open(env.module, kind, attrs)
  end

  defp close_scope(:endpoint, env, _identifier) do
    close_scope_and_define_definition(env)
  end

  defp close_scope(_, env, _) do
    Scope.close(env.module)
  end

  defp close_scope_and_define_definition(env) do
    definition = build_definition(env)
    put_definition(env, definition)
    Scope.close(env.module)
  end

  defp build_definition(env) do
    endpoint = WechatBase.Api.Notation.Endpoint.build(env.module)
    name = Scope.namespace(env.module)
    description = Scope.attr(env.module, :description)
    reference = Scope.attr(env.module, :__reference__)
    definition = %Definition{identifier: name, endpoint: endpoint, desc: description || "", __reference__: reference}
    put_definition(env.module, definition)
  end

  defp put_definition(module, definition) do
    definitions = Module.get_attribute(module, :wechatex_definitions) || []
    Module.put_attribute(module, :wechatex_definitions, [definition | definitions])
  end

  defp decorate_env(:endpoint, env) do
    {env, _} = Code.eval_quoted(quote do
      import WechatBase.Api.Notation.Endpoint
      __ENV__
    end, [], env)
  end
  defp decorate_env(_kind, env), do: env

  def add_reference(attrs, env, identifier) do
    attrs
    |> Keyword.put(
      :__reference__,
      Macro.escape(%{
        module: env.module,
        identifier: identifier,
        location: %{
          file: env.file,
          line: env.line
        }
      })
    )
  end

  defp add_description(attrs, env) do
    case Module.get_attribute(env.module, :__wechatex_desc__) do
      nil ->
        attrs
      desc ->
        Module.put_attribute(env.module, :__wechatex_desc__, nil)
        Keyword.put(attrs, :description, reformat_description(desc))
    end
  end

  defp reformat_description(text), do: String.trim(text)
end