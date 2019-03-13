defmodule Exenv.Adapters.Yaml do
  @moduledoc """
  Loads env vars from `.yml` files.

  You can use this adapter by adding it to your `:exenv` application config. The
  options available can be seen in the `load/1` function.

      config :exenv,
        adapters: [
          {Exenv.Adapters.Yaml, []}
        ]

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

  This adapter supports secrets encryption. Please see `Exenv.Encryption` for
  more details on how to get that set up.

  """

  use Exenv.Adapter

  alias Exenv.Adapters.Yaml.Parser

  @keys [Mix.env() |> to_string()]

  defguardp is_env_val(val) when is_binary(val) or is_number(val) or is_boolean(val)

  @doc """
  Loads the system env vars from a `.yml` specified in the options.

  ## Options
    * `:file` - The file path in which to read the `.yml` from. By default this
    is a `secrets.yml` file in your projects root directory.
    * `:keys` - A list of string keys within the `yml` file to use for the secrets.
    By default this is just the value from `Mix.env/0`.
    * `:encryption` - options used to decrypt files. Please see `Exenv.read_file/2`
    for the options available.

  ## Example

      Exenv.Adapters.Yaml.load(file: "/path/to/file.yml", keys: ["common", "dev"])

  """
  @impl true
  def load(opts) do
    opts = get_opts(opts)

    with {:ok, env_file} <- get_env_file(opts),
         {:ok, env_vars} <- parse(env_file, opts[:keys]) do
      System.put_env(env_vars)
    end
  end

  defp get_opts(opts) do
    default_opts = [file: File.cwd!() <> "/secrets.yml", keys: @keys]
    Keyword.merge(default_opts, opts)
  end

  defp get_env_file(opts) do
    file = Keyword.get(opts, :file)
    Exenv.read_file(file, opts)
  end

  defp parse(env_file, keys) do
    with {:ok, yaml} <- Parser.read(env_file) do
      parse_yaml(yaml, keys)
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

  defp parse_var({key, val}) when is_binary(key) and is_env_val(val) do
    with {:ok, key} <- safe_stringify(key),
         {:ok, val} <- safe_stringify(val) do
      {key |> String.upcase(), val}
    end
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

  defp safe_stringify(val) do
    {:ok, val |> to_string() |> String.trim()}
  rescue
    _ -> nil
  end
end
