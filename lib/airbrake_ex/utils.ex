defmodule AirbrakeEx.Utils do
  @filtered_value "***"

  def filter(input, nil), do: input

  def filter(struct, filter_params) when is_struct(struct) do
    struct |> Map.from_struct() |> filter(filter_params)
  end

  def filter(map, filter_params) when is_map(map) do
    Enum.into(map, %{}, &filter_key_value(&1, filter_params))
  end

  def filter(list, filter_params) when is_list(list) do
    Enum.map(list, &filter(&1, filter_params))
  end

  def filter(other, _filtered_attributes), do: other

  defp filter_key_value({k, v}, filter_params) when is_list(filter_params) do
    if Enum.member?(filter_params, stringify(k)) do
      {k, @filtered_value}
    else
      {k, filter(v, filter_params)}
    end
  end

  defp filter_key_value({k, v}, filter_params) when is_function(filter_params) do
    if filter_params.(k) do
      {k, @filtered_value}
    else
      {k, filter(v, filter_params)}
    end
  end

  defp stringify(atom) when is_atom(atom), do: Atom.to_string(atom)
  defp stringify(string) when is_binary(string), do: string

  def detuple(%module{} = struct) do
    fields = struct |> Map.from_struct() |> detuple()
    struct(module, fields)
  end

  def detuple(map) when is_map(map) do
    Enum.into(map, %{}, fn {k, v} -> {detuple(k), detuple(v)} end)
  end

  def detuple(list) when is_list(list) do
    Enum.map(list, &detuple/1)
  end

  def detuple(tuple) when is_tuple(tuple) do
    tuple |> Tuple.to_list() |> detuple()
  end

  def detuple(other) do
    other
  end
end
