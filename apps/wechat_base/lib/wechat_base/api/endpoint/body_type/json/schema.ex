defmodule WechatBase.Api.Endpoint.BodyType.Json.Schema do

  alias WechatBase.Error

  alias WechatBase.Maps

  @type primary_type :: :string | :integer | :float

  @type node_type :: primary_type | {:array, node_type} | :object | {:map, node_type}

  @type node_opts :: %{required?: boolean}

  @type id_t :: string | atom

  @type schema_node :: {node_type, id_t, node_opts, [schema_node]}
  
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

  defp validate_schema_node!({node_type, identifier, node_opts, children}, prefix) do
    identifier = validate_schema_identifier!(identifier, prefix)
    prefix = "#{prefix}.#{identifier}"
    node_type = validate_schema_node_type!(node_type, prefix)
    validate_node_type_and_children!(node_type, children, prefix)
    {node_type, identifier, node_opts, validate_schema_children!(children, prefix)}
  end

  defp validate_schema_node!(illegal_node, prefix) do
    raise ArgumentError, "Illegal node, expecting {primary_type, identifier, opts} or {compose_type, identifier, opts, children}, but got #{inspect illegal_node} at #{inspect prefix}"
  end

  defp validate_node_type_and_children!(primary_type, [], prefix) when primary_type in @primary_type do
    :ok
  end

  defp validate_node_type_and_children!(primary_type, non_empty_children, prefix) when primary_type in @primary_type do
    raise ArgumentError, "Illegal node, node of primary_type cannot have any child but get #{inspect non_empty_children} at #{inspect prefix}"
  end

  defp validate_node_type_and_children!(:object, _children, _prefix) do
    :ok
  end

  defp validate_node_type_and_children!({compose_type, node_type}, children, prefix) do
    validate_node_type_and_children!(node_type, children, prefix)
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

  @type error :: {String.t, {String.t, Keyword.t}}

  @type body_context :: %{errors: [error], prefix: [String.t]}

  def validate_body(schema, body) do
    context = validate_object(init_body_context, schema, body)
    if Enum.empty?(context.errors) do
      :ok
    else
      {:error, Error.new(:illegal_body, "Validate body %{body} error: %{errors}", %{body: body, errors: context.errors})}
    end
  end

  defp validate_object(context, nodes, nil) do
    validate_object(context, nodes, %{})
  end

  defp validate_object(context, [], _body) do
    context
  end

  defp validate_object(context, [node|tail], body) when is_map(body) do
    validate_node(context, node, Maps.get_string_or_atom_field(body, elem(node, 1)))
    |> validate_object(tail, body)
  end

  defp validate_node(context, {_, identifier, %{required?: true}, _}, nil) do
    context
    |> put_error(identifier, "is required")
  end
  defp validate_node(context, {_, identifier, %{required?: false}, _}, nil) do
    context
  end
  defp validate_node(context, {_, identifier, _, _}, nil) do
    context
  end

  defp validate_node(context, {primary_type, identifier, args, _}, value) when primary_type in @primary_type do
    if validate_value(primary_type, value) do
      context
    else
      context
      |> put_error(identifier, "should be a #{primary_type}", value: value)
    end
  end

  defp validate_node(context, {:object, identifier, args, children}, map) when is_map(map) do
    context
    |> push_prefix(identifier)
    |> validate_object(children, map)
    |> pop_prefix
  end

  defp validate_node(context, {:object, identifier, _args, children}, not_map) do
    context
    |> put_error(identifier, "should be a map", value: not_map)
  end

  defp validate_node(context, {{:array, type}, identifier, args, children}, list) when is_list(list) do
    list |> Enum.with_index |> Enum.reduce(context |> push_prefix(identifier), fn
      {child, index}, context ->
        context
        |> validate_node({type, index, args, children}, child)
    end) |> pop_prefix
  end

  defp validate_node(context, {{:array, type}, identifier, _, children}, not_list) do
    context
    |> put_error(identifier, "should be a list", value: not_list)
  end


  defp validate_node(context, {{:map, type}, identifier, args, children}, map) when is_map(map) do
    map |> Enum.reduce(context |> push_prefix(identifier), fn
      {key, child}, context ->
        context
        |> validate_node({type, key, args, children}, child)
    end) |> pop_prefix
  end

  defp validate_node(context, {{:map, type}, identifier, args, children}, not_map) do
    context
    |> put_error(identifier, "should be a map", value: not_map)
  end

  defp validate_value(:string, value) when is_binary(value), do: true
  defp validate_value(:integer, value) when is_integer(value), do: true
  defp validate_value(:float, value) when is_float(value) or is_integer(value), do: true
  defp validate_value(_, value), do: false

  defp init_body_context() do
    %{errors: [], prefix: []}
  end

  defp put_error(context, identifier, message, keyword \\ []) do
    context = push_prefix(context, identifier)
    %{context | errors: [{prefix(context.prefix), {message, keyword}} | context.errors]}
    |> pop_prefix
  end

  defp prefix(prefix) do
    Enum.reverse(prefix) |> Enum.join
  end

  defp push_prefix(%{prefix: []} = context, prefix) when is_binary(prefix) or is_atom(prefix) do
    %{context | prefix: [prefix]}
  end

  defp push_prefix(%{prefix: prefixes} = context, prefix) when is_binary(prefix) or is_atom(prefix) do
    %{context | prefix: [".#{prefix}" | prefixes]}
  end

  defp push_prefix(context, prefix) when is_integer(prefix) do
    %{context | prefix: ["[#{prefix}]" | context.prefix]}
  end

  defp pop_prefix(context) do
    [_|prefix] = context.prefix
    %{context | prefix: prefix}
  end

end