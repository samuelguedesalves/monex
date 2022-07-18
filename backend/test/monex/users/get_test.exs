defmodule Monex.Users.GetTest do
  use Monex.DataCase, async: true

  alias Monex.{Error, User, Users}

  import Monex.Factory

  describe "by_cpf/1" do
    setup do
      %User{cpf: cpf} = insert(:user)

      %{cpf: cpf}
    end

    test "when cpf is valid and user exist on database, should return user", %{cpf: cpf} do
      assert {:ok, %User{}} = Users.Get.by_cpf(cpf)
    end

    test "when cpf is invalid, return error" do
      expected_response = %Error{status: :bad_request, result: "cpf should be valid"}

      assert expected_response == Users.Get.by_cpf("00000000000")
    end

    test "when user is not found, return error not found" do
      expected_response = %Error{status: :not_found, result: "user is not found"}

      assert expected_response == Users.Get.by_cpf("64445164208")
    end
  end

  describe "by_id/1" do
    setup do
      %User{id: id} = insert(:user)

      %{id: id}
    end

    test "when id exist on database, return the user", %{id: id} do
      assert {:ok, %User{}} = Users.Get.by_id(id)
    end
  end
end
