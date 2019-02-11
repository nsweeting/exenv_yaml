# Exenv Yaml

This is a YAML adapter for [Exenv](https://github.com/nsweeting/exenv).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `exenv_yaml` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exenv, "~> 0.2"},
    {:exenv_yaml, "~> 0.1.0"}
  ]
end
```

## Documentation

Further documentaion can be be found at [https://hexdocs.pm/exenv_yaml](https://hexdocs.pm/exenv_yaml).

## Getting Started

Please consult the documentation for [Exenv](https://github.com/nsweeting/exenv) to
understand its basic usage.

This package extends `Exenv` my adding the ability to load system env vars from a typical `"secrets.yml"` file that is laid out using the current environment. Below is an
example:

```yml
prod:
  key: val

dev:
  key: val

test:
  key: val
```

You can then add this adapter to your configuration:

```elixir
config :exenv, [
  adapters: [
    {Exenv.Adapters.YAML, [file: "path/to/secrets.yml"]}
  ]
]
```

By default, the file will be a `secrets.yml` file in your projects root directory.
