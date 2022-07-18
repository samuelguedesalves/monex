defmodule Monex.UserTest do
  use Monex.DataCase, async: true

  alias Ecto.Changeset
  alias Monex.User

  import Monex.Factory

  describe "changeset/1" do
    test "when all params are valid, should return an valid user changeset" do
      params = build(:user_params)

      response = User.changeset(params)

      assert %Changeset{valid?: true, changes: %{}} = response
    end

    test "when are an invalid param, should return a invalid user changeset" do
      params = build(:user_params, %{"password" => "123"})

      response = User.changeset(params)

      expected_response = %{password: ["should be at least 6 character(s)"]}

      assert errors_on(response) == expected_response
    end
  end
end
