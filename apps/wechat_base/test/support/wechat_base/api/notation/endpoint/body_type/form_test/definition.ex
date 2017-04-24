defmodule WechatBase.Api.Notation.Endpoint.BodyType.FormTest.Definition do

  alias WechatBase.Api.Notation.Endpoint.BodyType.Form

  defmacro __using__(_args) do
    quote do
      import unquote(__MODULE__), only: :macros
    end
  end

  defmacro eval(name, [do: block]) do
    do_eval(__CALLER__, name, block)
  end

  defp do_eval(env, name, block) do
    {module, args} = Form.eval(env, [], block)
    quote do
      def form(unquote(name)) do
        {unquote(module), unquote(args |> Macro.escape)}
      end
    end
  end
end
