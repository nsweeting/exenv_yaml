# Exenv Yaml

[![Build Status](https://travis-ci.org/nsweeting/exenv_yaml.svg?branch=master)](https://travis-ci.org/nsweeting/exenv_yaml)
[![Exenv Yaml Version](https://img.shields.io/hexpm/v/exenv_yaml.svg)](https://hex.pm/packages/exenv_yaml)

This is a YAML adapter for [Exenv](https://github.com/nsweeting/exenv).

## Installation

This package can be installed by adding `exenv_yaml` to your list of dependencies in `mix.exs`.

```elixir
def deps do
  [
    {:exenv_yaml, "~> 0.3"}
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
    {Exenv.Adapters.Yaml, [file: "path/to/secrets.yml"]}
  ]
]
```

By default, the file will be a `secrets.yml` file in your projects root directory.
