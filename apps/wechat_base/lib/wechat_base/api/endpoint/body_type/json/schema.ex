defmodule WechatBase.Api.Endpoint.BodyType.Json.Schema do

  alias WechatBase.Error

  alias WechatBase.Maps

  @type primary_type :: :string | :integer | :float

  @type node_type :: primary_type | {:array, node_type} | :object | {:map, node_type}

  @type node_opts :: %{required?: boolean}

  @type id_t :: string | atom

  @type primary_node :: {primary_type, id_t, node_opts}

  @type compose_node :: {{:array, node_type}, id_t, node_opts, [schema_node]}
                      | {{:map, node_type}, id_t, node_opts, [schema_node]}
                      | {:object, id_t, node_opts, [schema_node]}

  @type schema_node :: primary_node | compose_node

  @type t :: [schema_node]

  @primary_type [:string, :integer, :float]



  def validate!(schema) do
    validate_schema_children!(schema, "")
  end

  defp validate_schema_children!(nil, _prefix) do
    []
  end

  defp validate_schema_children!(children, prefix) when is_list(children) do
    Enum.map(children, &validate_schema_node!(&1, prefix))
  end

  defp validate_schema_children!(illegal_children, prefix) do
    raise ArgumentError, "Illegal children, expecting a list but got #{inspect illegal_children} at #{inspect prefix}"
  end

  defp validate_schema_node!({node_type, identifier, node_opts}, prefix) when node_type in @primary_type do
    identifier = validate_schema_identifier!(identifier, prefix)
    prefix = "#{prefix}.#{identifier}"
    {validate_schema_node_type!(node_type, prefix), identifier, node_opts}
  end

  defp validate_schema_node!({illegal_node_type, identifier, _node_opts}, prefix) do
    prefix = "#{prefix}.#{identifier}"
    raise ArgumentError, "Illegal node_type, expecting #{inspect @primary_type} but got #{inspect illegal_node_type} at #{inspect prefix}"
  end

  defp validate_schema_node!({node_type, identifier, node_opts, children}, prefix) do
    identifier = validate_schema_identifier!(identifier, prefix)
    prefix = "#{prefix}.#{identifier}"
    {validate_schema_node_type!(node_type, prefix), identifier, node_opts, validate_schema_children!(children, prefix)}
  end

  defp validate_schema_node!(illegal_node, prefix) do
    raise ArgumentError, "Illegal node, expecting {primary_type, identifier, opts} or {compose_type, identifier, opts, children}, but got #{inspect illegal_node} at #{inspect prefix}"
  end

  defp validate_schema_node_type!(node_type, prefix) when node_type in @primary_type or node_type == :object do
    node_type
  end

  defp validate_schema_node_type!({:array, node_type}, prefix) do
    {:array, validate_schema_node_type!(node_type, prefix)}
  end

  defp validate_schema_node_type!({:map, node_type}, prefix) do
    {:map, validate_schema_node_type!(node_type, prefix)}
  end

  defp validate_schema_node_type!(illegal_node_type, prefix) do
    raise ArgumentError, "Illegal node_type #{inspect illegal_node_type} at #{inspect prefix}"
  end

  defp validate_schema_identifier!(identifier, prefix) when is_atom(identifier) or is_binary(identifier) do
    identifier
  end

  defp validate_schema_identifier!(illegal_identifier, prefix) do
    raise ArgumentError, "Illegal identifier #{inspect illegal_identifier} at #{inspect prefix}"
  end
end