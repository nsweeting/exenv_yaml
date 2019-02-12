defmodule Exenv.Adapters.Yaml do
  @moduledoc """
  Loads env vars from `.yml` files.

  Below is a simple example of a `.yml` file:

      prod:
        key1: val
        key2: val

      dev:
        key1: val
        key2: val

      test:
        key1: val
        key2: val

  Assuming we have the above file in our project root directory, we would be
  able to access any of the above environment vars.

      System.get_env("KEY1")

  """

  use Exenv.Adapter

  @keys [Mix.env() |> to_string()]

  @doc """
  Loads the system env vars from a `.yml` specified in the options.

  ## Options
    * `:file` - The file path in which to read the `.yml` from. By default this
    is a `secrets.yml` file in your projects root directory.
    * `:keys` - A list of string keys within the YAML file to use for the secrets. By
    default this is just the value from `Mix.env/0`.
  """
  @impl true
  def load(opts) do
    opts = get_opts(opts)

    with {:ok, env_vars} <- parse(opts) do
      System.put_env(env_vars)
    end
  end

  defp get_opts(opts) do
    default_opts = [file: File.cwd!() <> "/secrets.yml", keys: @keys]
    Keyword.merge(default_opts, opts)
  end

  defp parse(opts) do
    with {:ok, raw} <- File.read(opts[:file]),
         {:ok, yaml} <- read_yaml(raw) do
      parse_yaml(yaml, opts[:keys])
    end
  end

  defp read_yaml(raw) do
    case YamlElixir.read_from_string(raw) do
      {:error, _} -> {:error, :malformed_yaml}
      result -> result
    end
  end

  defp parse_yaml(yaml, keys) when is_map(yaml) and is_list(keys) do
    env_vars =
      yaml
      |> Map.take(keys)
      |> Map.values()
      |> Stream.flat_map(& &1)
      |> Stream.map(&parse_var/1)
      |> Stream.filter(&(valid_var?(&1) == true))
      |> Enum.to_list()

    {:ok, env_vars}
  end

  defp parse_yaml(_yaml, _env) do
    {:error, :malformed_yaml}
  end

  defp parse_var({key, val}) when is_binary(key) and is_binary(val) do
    {key |> String.trim() |> String.upcase(), String.trim(val)}
  end

  defp parse_var(_var) do
    :error
  end

  defp valid_var?({key, val}) when is_binary(key) and is_binary(val) do
    true
  end

  defp valid_var?(_) do
    false
  end
end
