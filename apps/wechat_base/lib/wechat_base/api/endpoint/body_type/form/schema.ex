defmodule WechatBase.Api.Endpoint.BodyType.Form.Schema do

  alias WechatBase.Error

  alias WechatBase.Maps

  alias WechatBase.Api.Endpoint.BodyType.FileValidator

  @type node_type :: :file | :string | :integer | :float | :json

  @type id_t :: String.t | atom

  @type opts :: %{required?: boolean}

  @type schema_node :: {node_type, id_t, opts}

  @type t :: [schema_node]

  @primary_type [:string, :integer, :float, :json]

  @node_types [:file] ++ @primary_type

  @type validate!(t) :: t | no_return
  def validate!(schema) when is_list(schema) do
    Enum.map(schema, &validate_schema_node!/1)
  end

  def validate!(schema) do
    raise ArgumentError, "Schema should be a list but got #{inspect schema}"
  end

  defp validate_schema_node!({node_type, identifier, opts}) do
    {validate_node_type!(node_type), validate_identifier!(identifier), opts}
  end

  defp validate_node_type!(node_type) when node_type in @node_types do
    node_type
  end

  defp validate_node_type!(illegal_node_type) do
    raise ArgumentError, "Illegal node type, expecting #{inspect @node_types} but got #{inspect illegal_node_type}"
  end

  defp validate_identifier!(identifier) when is_binary(identifier) or is_atom(identifier) do
    identifier
  end

  defp validate_identifier!(illegal_identifier) do
    raise ArgumentError, "Illegal identifier, expecting a string or atom but got #{inspect illegal_identifier}"
  end

  @spec validate_body(t, Map.t) :: :ok | {:error, Error.t}
  def validate_body(schema, body) when is_map(body) do
    errors = Enum.reduce(schema, [], fn
      node, errors ->
        validate_node(node, Maps.get_string_or_atom_field(body, elem(node, 1)), errors)
    end)
    if Enum.empty?(errors) do
      :ok
    else
      {:error, Error.new(:illegal_body, "Validate body %{body} error: %{errors}", %{body: body, errors: errors})}
    end
  end

  def validate_body(_schema, illegal_body) do
    {:error, Error.new(:illegal_body, "Validate body %{body} error: expecting a map", %{body: illegal_body})}
  end

  defp validate_node({_, identifier, %{required?: true}}, nil, errors) do
    errors
    |> put_error(identifier, "is required")
  end

  defp validate_node({_, _, %{}}, nil, errors) do
    errors
  end

  defp validate_node({:file, identifier, args}, path, errors) when is_binary(path) do
    case FileValidator.validate(path, args) do
      :ok ->
        errors
      {:error, {message, args}} ->
        errors |> put_error(identifier, message, args)
    end
  end

  defp validate_node({:file, identifier, _}, value, errors) do
    errors |> put_error(identifier, "should be a path", value: value)
  end

  defp validate_node({primary_type, identifier, _}, value, errors) do
    if validate_value(primary_type, value) do
      errors
    else
      errors |> put_error(identifier, "should be #{primary_type}", value: value)
    end
  end

  defp validate_value(:string, value) when is_binary(value), do: true
  defp validate_value(:integer, value) when is_integer(value), do: true
  defp validate_value(:float, value) when is_float(value) or is_integer(value), do: true
  defp validate_value(:json, value) when is_map(value) or is_binary(value) or is_number(value), do: true
  defp validate_value(_, _value), do: false

  defp put_error(errors, identifier, message, args \\ []) do
    [{identifier, {message, args}} | errors]
  end
end