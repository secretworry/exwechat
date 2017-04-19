defmodule WechatBase.Conn.Utils do

  @type params :: %{binary => binary}

  @upper ?A..?Z
  @lower ?a..?z
  @alpha ?0..?9
  @other [?., ?-, ?+]
  @space [?\s, ?\t]
  @specials ~c|()<>@,;:\\"/[]?={}|

  @spec media_type(binary) :: {:ok, type :: binary, subtype :: binary, params} | :error
  def media_type(binary) do
    case strip_spaces(binary) do
      "*/*" <> t -> mt_params(t, "*", "*")
      t -> mt_first(t, "")
    end
  end

  defp mt_first(<<?/, t :: binary>>, acc) when acc != "",
    do: mt_wildcard(t, acc)
  defp mt_first(<<h, t :: binary>>, acc) when h in @upper,
    do: mt_first(t, <<acc :: binary, downcase_char(h)>>)
  defp mt_first(<<h, t :: binary>>, acc) when h in @lower or h in @alpha or h == ?-,
    do: mt_first(t, <<acc :: binary, h>>)
  defp mt_first(_, _acc),
    do: :error

  defp mt_wildcard(<<?*, t :: binary>>, first),
    do: mt_params(t, first, "*")
  defp mt_wildcard(t, first),
    do: mt_second(t, "", first)

  defp mt_second(<<h, t :: binary>>, acc, first) when h in @upper,
    do: mt_second(t, <<acc :: binary, downcase_char(h)>>, first)
  defp mt_second(<<h, t :: binary>>, acc, first) when h in @lower or h in @alpha or h in @other,
    do: mt_second(t, <<acc :: binary, h>>, first)
  defp mt_second(t, acc, first),
    do: mt_params(t, first, acc)

  defp mt_params(t, first, second) do
    case strip_spaces(t) do
      ""       -> {:ok, first, second, %{}}
      ";" <> t -> {:ok, first, second, params(t)}
      _        -> :error
    end
  end
  
  def params(t) do
    t
    |> split_semicolon("", [], false)
    |> Enum.reduce(%{}, &params/2)
  end
  defp params(param, acc) do
    case params_key(strip_spaces(param), "") do
      {k, v} -> Map.put(acc, k, v)
      false  -> acc
    end
  end

  defp params_key(<<?=, t :: binary>>, acc) when acc != "",
    do: params_value(t, acc)
  defp params_key(<<h, _ :: binary>>, _acc) when h in @specials or h in @space or h < 32 or h === 127,
    do: false
  defp params_key(<<h, t :: binary>>, acc),
    do: params_key(t, <<acc :: binary, downcase_char(h)>>)
  defp params_key(<<>>, _acc),
    do: false

  defp params_value(token, key) do
    case token(token) do
      false -> false
      value -> {key, value}
    end
  end

  @spec token(binary) :: binary | false
  def token(""),
    do: false
  def token(<<?", quoted :: binary>>),
    do: quoted_token(quoted, "")
  def token(token),
    do: unquoted_token(token, "")

  defp quoted_token(<<>>, _acc),
    do: false
  defp quoted_token(<<?", t :: binary>>, acc),
    do: strip_spaces(t) == "" and acc
  defp quoted_token(<<?\\, h, t :: binary>>, acc),
    do: quoted_token(t, <<acc :: binary, h>>)
  defp quoted_token(<<h, t :: binary>>, acc),
    do: quoted_token(t, <<acc :: binary, h>>)

  defp unquoted_token(<<>>, acc),
    do: acc
  defp unquoted_token("\r\n" <> t, acc),
    do: strip_spaces(t) == "" and acc
  defp unquoted_token(<<h, t :: binary>>, acc) when h in @space,
    do: strip_spaces(t) == "" and acc
  defp unquoted_token(<<h, _ :: binary>>, _acc) when h in @specials or h < 32 or h === 127,
    do: false
  defp unquoted_token(<<h, t :: binary>>, acc),
    do: unquoted_token(t, <<acc :: binary, h>>)

  defp downcase_char(char) when char in @upper, do: char + 32
  defp downcase_char(char), do: char

  defp strip_spaces("\r\n" <> t),
    do: strip_spaces(t)
  defp strip_spaces(<<h, t :: binary>>) when h in [?\s, ?\t],
    do: strip_spaces(t)
  defp strip_spaces(t),
    do: t
  
  defp split_semicolon(<<>>, <<>>, acc, _),
    do: acc
  defp split_semicolon(<<>>, buffer, acc, _),
    do: [buffer | acc]
  defp split_semicolon(<<?", rest::binary>>, buffer, acc, quoted?),
    do: split_semicolon(rest, <<buffer::binary, ?">>, acc, not quoted?)
  defp split_semicolon(<<?;, rest::binary>>, buffer, acc, false),
    do: split_semicolon(rest, <<>>, [buffer | acc], false)
  defp split_semicolon(<<char, rest::binary>>, buffer, acc, quoted?),
    do: split_semicolon(rest, <<buffer::binary, char>>, acc, quoted?)
end