defmodule Exenv.Adapters.Yaml.Parser do
  @yamerl_options [
    detailed_constr: true,
    str_node_as_binary: true
  ]

  @spec read(binary() | charlist()) :: {:ok, map()} | {:error, :malformed_yaml}
  def read(yaml) do
    yaml
    |> :yamerl_constr.string(@yamerl_options)
    |> List.first()
    |> process()
    |> result()
  catch
    _, _ -> {:error, :malformed_yaml}
  end

  defp process(nil), do: %{}
  defp process(yaml) when is_list(yaml), do: Enum.map(yaml, &process(&1))
  defp process(yaml), do: _to_map(yaml)

  defp result(nil), do: {:ok, %{}}
  defp result(map), do: {:ok, map}

  defp _to_map({:yamerl_doc, document}), do: _to_map(document)

  defp _to_map({:yamerl_seq, :yamerl_node_seq, _tag, _loc, seq, _n}),
    do: Enum.map(seq, &_to_map(&1))

  defp _to_map({:yamerl_map, :yamerl_node_map, _tag, _loc, map_tuples}),
    do: _tuples_to_map(map_tuples, %{})

  defp _to_map(
         {:yamerl_str, :yamerl_node_str, _tag, _loc, <<?:, _::binary>> = element}),
       do: element

  defp _to_map({:yamerl_null, :yamerl_node_null, _tag, _loc}), do: nil
  defp _to_map({_yamler_element, _yamler_node_element, _tag, _loc, elem}), do: elem

  defp _tuples_to_map([], map), do: map

  defp _tuples_to_map([{key, val} | rest], map) do
    case key do
      {:yamerl_seq, :yamerl_node_seq, _tag, _log, _seq, _n} ->
        map = Map.put_new(map, _to_map(key), _to_map(val))
        _tuples_to_map(rest, map)

      {_yamler_element, _yamler_node_element, _tag, _log, name} ->
        map = Map.put_new(map, name, _to_map(val))
        _tuples_to_map(rest, map)
    end
  end
end
