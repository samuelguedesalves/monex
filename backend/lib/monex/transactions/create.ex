defmodule Monex.Transactions.Create do
  alias Ecto.Changeset
  alias Monex.{Error, Repo, Transaction, User, Users}

  import Ecto.Query

  @doc """
  call/2

  Create a transaction

  ## Params:
  - params: map that contains the transaction attributes
    - amount: number that represents the amount of the transaction
    - to_user_cpf: string that represents the receiver user cpf
    - from_user_id: string that represents the  sender user id

  ## Example

      iex> Monex.Transactions.Create.call(%{
      ..      amount: 2000,
      ..      to_user_cpf: "27024081171"
      ..      from_user_id: "503ab4a1-f7cb-4197-8af7-efb72c13ffeb"
      ..   })

      {:ok, %Monex.Transaction{}}
      # or
      %Monex.Error{}
  """
  @spec call(
          params :: %{
            amount: integer(),
            to_user_cpf: String.t(),
            from_user_id: Ecto.UUID.t()
          }
        ) :: {:ok, Transaction.t()} | Error.t()

  def call(%{amount: amount, to_user_cpf: to_user_cpf, from_user_id: from_user_id}) do
    Repo.transaction(fn ->
      with {:ok, %{total_amount: total_amount}} <- Users.GetAmount.call(from_user_id),
           {:ok, receiver_user_id} <- cast_receiver_user_cpf(to_user_cpf),
           :ok <- validate_id_difference(from_user_id, receiver_user_id),
           {:ok, params} <- mount_params(total_amount, amount, receiver_user_id, from_user_id),
           {:ok, result} <- create_transaction(params) do
        result
      else
        reason -> Repo.rollback(reason)
      end
    end)
    |> handle_transaction_result()
  end

  defp cast_receiver_user_cpf(user_cpf) do
    query =
      from u in User,
        where: u.cpf == ^user_cpf,
        select: u.id

    case Repo.one(query) do
      nil -> Error.build(:bad_request, "invalid receiver user cpf")
      user_id -> {:ok, user_id}
    end
  end

  defp validate_id_difference(first_id, second_id) do
    if first_id != second_id,
      do: :ok,
      else: Error.build(:bad_request, "can not send a transaction to your self")
  end

  defp mount_params(total_amount, amount, to_user, from_user) do
    if total_amount >= amount do
      params = %{amount: amount, to_user: to_user, from_user: from_user}
      {:ok, params}
    else
      Error.build(:bad_request, "invalid amount available")
    end
  end

  defp create_transaction(params) do
    params
    |> Transaction.changeset()
    |> Repo.insert()
    |> case do
      {:error, %Changeset{} = changeset} -> Error.build(:bad_request, changeset)
      {:ok, %Transaction{}} = result -> result
    end
  end

  defp handle_transaction_result({:error, %Error{} = error}), do: error
  defp handle_transaction_result(result), do: result
end
