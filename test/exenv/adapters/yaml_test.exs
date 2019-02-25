defmodule Exenv.Adapters.YamlTest do
  use ExUnit.Case

  import Exenv.Test

  alias Exenv.Adapters.Yaml

  @test_yaml File.cwd!() <> "/test/fixtures/secrets.yml"
  @bad_yaml1 File.cwd!() <> "/test/fixtures/bad1.yml"
  @bad_yaml2 File.cwd!() <> "/test/fixtures/bad2.yml"
  @bool_yaml File.cwd!() <> "/test/fixtures/bool.yml"
  @num_yaml File.cwd!() <> "/test/fixtures/num.yml"
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
      vars = @test_vars ++ [{"GOOD_KEY3", "baz"}]
      refute_vars(vars)

      Yaml.load(file: @test_yaml, keys: ["dev", "other"])

      assert_vars(vars)
    end

    test "will set env vars from boolean values" do
      vars = [{"BOOL1", "true"}, {"BOOL2", "false"}]
      refute_vars(vars)

      Yaml.load(file: @bool_yaml, keys: ["boolean"])

      assert_vars(vars)
    end

    test "will set env vars from number values" do
      vars = [{"NUM1", "1"}, {"NUM2", "1.0"}]
      refute_vars(vars)

      Yaml.load(file: @num_yaml, keys: ["number"])

      assert_vars(vars)
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
