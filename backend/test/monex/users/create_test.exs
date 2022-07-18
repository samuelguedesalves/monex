defmodule Monex.Users.CreateTest do
  use Monex.DataCase, async: true

  alias Monex.{AuthGuardian, Error, User, Users}

  import Monex.Factory

  describe "call/1" do
    test "when all params are valid, should return a valid user insertion" do
      params = build(:user_params)

      response = Users.Create.call(params)

      assert {:ok, %User{id: id}, token} = response
      assert {:ok, %{"sub" => sub}} = AuthGuardian.decode_and_verify(token)
      assert id == sub
    end

    test "when cpf params are invalid, return error struct with invalid changeset" do
      params = build(:user_params, %{"cpf" => "00000000000"})

      expected_changeset_error = %{cpf: ["cpf sould be valid"]}

      assert %Error{status: :bad_request, result: changeset} = Users.Create.call(params)
      assert errors_on(changeset) == expected_changeset_error
    end

    test "when initial amount params is invalid, return error struct with invalid changeset" do
      params = build(:user_params, %{"initial_amount" => 0})

      expected_changeset_error = %{initial_amount: ["initial_amount should be positive"]}

      assert %Error{status: :bad_request, result: changeset} = Users.Create.call(params)
      assert errors_on(changeset) == expected_changeset_error
    end
  end
end
