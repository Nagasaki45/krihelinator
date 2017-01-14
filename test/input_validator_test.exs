defmodule Krihelinator.InputValidatorTest do
  use Krihelinator.ConnCase, async: true

  import Krihelinator.InputValidator

  # Default values for most tests
  @params %{"name" => "moshe"}
  @field "name"
  @allowed ~w(moshe jacob)
  @default :jacob

  test "verify_field against allowed values" do
    assert verify_field(@params, @field, @allowed, @default) == {:ok, :moshe}
  end

  test "verify_field invalid value against allowed values" do
    params = %{"name" => "yossi"}
    {result, _whatever} = verify_field(params, @field, @allowed, @default)
    assert result == :error
  end

  test "verify_field field doesn't exist result with default" do
    field = "age"
    assert verify_field(@params, field, @allowed, @default) == {:ok, :jacob}
  end

  test "verify_field with parsing function instead of allowed value" do
    params = %{"data" => "{\"name\": \"moshe\", \"age\": 30}"}
    expected = %{"name" => "moshe", "age" => 30}
    result = verify_field(params, "data", &Poison.decode/1, %{})
    assert result == {:ok, expected}
  end

  test "verify_field with parsing function and wrong value" do
    params = %{"data" => "{\"name\": \"mo"}
    {result, _whatever} = verify_field(params, "data", &Poison.decode/1, %{})
    assert result == :error
  end
end
