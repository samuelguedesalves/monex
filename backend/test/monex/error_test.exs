defmodule Monex.ErrorTest do
  use ExUnit.Case

  alias Monex.Error

  describe "build/2" do
    test "when put a status and a result, return a error struct with fields" do
      assert %Error{status: :any, result: "any"} == Error.build(:any, "any")
    end
  end
end
