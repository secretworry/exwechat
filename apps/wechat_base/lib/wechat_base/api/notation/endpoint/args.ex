defmodule WechatBase.Api.Notation.Endpoint.Args do

  alias WechatBase.Api.Endpoint.Arg

  @args :__wechatex_args__

  def eval(block, env) do
    env = decorate_env(env)
    block |> expand(env)
    build_args(env.module)
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

  defmacro required(name) do
    record_arg(__CALLER__, name, true)
  end

  defmacro optional(name) do
    record_arg(__CALLER__, name, false)
  end

  defp record_arg(env, name, required, validator \\ nil) do
    arg = %Arg{name: name, required?: required, validator: validator}
    put_arg(env.module, arg)
  end

  defp put_arg(module, arg) do
    args = Module.get_attribute(module, @args) || []
    Module.put_attribute(module, @args, [arg | args])
  end

  defp build_args(module) do
    args = Module.get_attribute(module, @args) || []
    Module.delete_attribute(module, @args)
    args |> Enum.reverse
  end
end