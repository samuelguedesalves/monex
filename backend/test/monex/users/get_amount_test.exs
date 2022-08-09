defmodule Monex.Users.GetAmountTest do
  use Monex.DataCase, async: true

  alias Monex.{Error, User, Users}

  import Monex.Factory

  test "when user id is valid, return amount" do
    %User{id: sender_user_id} = insert(:user, %{initial_amount: 20_000})
    %User{id: receiver_user_id} = insert(:user, %{name: "Gabriel", cpf: Brcpfcnpj.cpf_generate()})

    insert(:transaction, %{amount: 10_000, from_user: sender_user_id, to_user: receiver_user_id})

    result = Users.GetAmount.call(sender_user_id)

    assert {:ok, %{total_amount: 10_000, outcome_amount: 10_000, income_amount: 0}} == result
  end

  test "when user id is invalid, return error" do
    result = Users.GetAmount.call(Ecto.UUID.generate())

    expected_response = %Error{result: "invalid user id", status: :internal_server_error}

    assert expected_response == result
  end
end
