defmodule WechatBase.Api.Notation.Endpoint.BodyType.JsonTest.Definition do

  alias WechatBase.Api.Notation.Endpoint.BodyType.Json

  defmacro __using__(args) do
    quote do
      import unquote(__MODULE__), only: :macros
    end
  end

  defmacro eval(name, [do: block]) do
    do_eval(__CALLER__, name, block)
  end

  defp do_eval(env, name, block) do
    {module, args} = Json.eval(env, [], block)
    quote do
      def json(unquote(name)) do
        {unquote(module), unquote(args |> Macro.escape)}
      end
    end
  end
end