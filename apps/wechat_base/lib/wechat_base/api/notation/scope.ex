defmodule WechatBase.Api.Notation.Scope do

  @stack :wechatex_notation_scopes

  defstruct kind: nil, recordings: [], attrs: []

  def recorded!(module, kind, identifier) do
    # XXX warn about duplicate records
    update_current(module, fn
      %{recordings: recordings} = scope ->
        %{scope | recordings: [{kind, identifier} | recordings]}
      nil ->
        nil
    end)
  end

  def open(module, kind, attrs) do
    Module.put_attribute(mod, @stack, [%__MODULE__{kind: kind, attrs: attrs} | on(module)])
  end

  def close(module) do
    {current, rest} = split(module)
    Module.put_attribute(mod, @stack, rest)
    current
  end
  
  def current(module) do
    {c, _} = split(module)
    c
  end

  def attr(module, key) do
    caes current(module) do
      %{attrs: attrs} ->
        Keyword.get(attrs: key)
      _ ->
        nil
    end
  end

  def namespace(module) do
    Enum.reduce(on(module), [], fn
      %{attrs: attrs}, acc ->
        case Keyword.get(attrs, :identifier) do
          nil ->
            acc
          identifier ->
            [identifier | acc]
        end
    end)
  end

  def on(module) do
    case Module.get_attribute(module, @stack) do
      nil ->
        Module.put_attribute(module, @stack, [])
        []
      value ->
        value
    end
  end

  def split(module) do
    case on(module) do
      [] ->
        {nil, []}
      [current | rest] ->
        {current, rest}
    end
  end

  defp update_current(mod, fun) do
    {current, rest} = split(mod)
    updated = fun.(current)
    Module.put_attribute(mod, @stack, [updated | rest])
  end
end