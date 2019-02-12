defmodule Exenv.Adapters.YamlTest do
  use ExUnit.Case

  import Exenv.Test

  alias Exenv.Adapters.Yaml

  @test_yaml File.cwd!() <> "/test/fixtures/secrets.yml"
  @bad_yaml1 File.cwd!() <> "/test/fixtures/bad1.yml"
  @bad_yaml2 File.cwd!() <> "/test/fixtures/bad2.yml"
  @test_vars [
    {"GOOD_KEY1", "foo"},
    {"GOOD_KEY2", "bar"}
  ]

  setup do
    setup_exenv(adapters: [{Exenv.Adapters.Yaml, []}])
    reset_env_vars(@test_vars)

    :ok
  end

  describe "load/1" do
    test "will set env vars from a specified yaml file" do
      refute_vars(@test_vars)

      Yaml.load(file: @test_yaml)

      assert_vars(@test_vars)
    end

    test "will set env vars from a specified yaml file and keys" do
      refute_vars(@test_vars)

      Yaml.load(file: @test_yaml, keys: ["dev"])

      assert_vars(@test_vars)
    end

    test "will return an error tuple when the file doesnt exist" do
      assert Yaml.load(file: "bad_file.yaml") == {:error, :enoent}
    end

    test "will return an error tuple when the file is a directory" do
      assert Yaml.load(file: "test") == {:error, :eisdir}
    end

    test "will return an error tuple for malformed yaml" do
      assert Yaml.load(file: @bad_yaml1) == {:error, :malformed_yaml}
    end

    test "will return an error tuple for improper formatted yaml" do
      assert Yaml.load(file: @bad_yaml2) == {:error, :malformed_yaml}
    end
  end
end
