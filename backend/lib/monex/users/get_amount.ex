defmodule Monex.Users.GetAmount do
  alias Monex.{Error, Repo, Transaction, User}

  import Ecto.Query

  @doc """
  call/1

  Get user total amount by id

  ## Params:
  - user_id: the uuid that represents the user identifier

  ## Example

      iex> Monex.Users.GetAmount("71a1d351-9ce0-4f02-b8e7-7d907f2796b6")

      {:ok, 2000}
      # or
      %Monex.Error{}
  """
  @spec call(Ecto.UUID.t()) :: {:ok, integer()} | Error.t()

  def call(user_id) do
    Repo.transaction(fn ->
      case get_initial_amount(user_id) do
        nil ->
          Error.build(:internal_server_error, "invalid user id")
          |> Repo.rollback()

        initial_amount ->
          income_amount = get_income_transactions_amount(user_id)
          outcome_amount = get_outcome_transactions_amount(user_id)

          total_amount = initial_amount + income_amount - outcome_amount
          {:ok, total_amount}
      end
    end)
    |> handle_transaction_result()
  end

  defp get_initial_amount(user_id) do
    query =
      from u in User,
        where: u.id == ^user_id,
        select: u.initial_amount

    Repo.one(query)
  end

  defp get_income_transactions_amount(user_id) do
    query =
      from t in Transaction,
        where: t.to_user == ^user_id,
        select: fragment("sum(?)", t.amount)

    case Repo.one(query) do
      nil -> 0
      income_amount -> income_amount
    end
  end

  defp get_outcome_transactions_amount(user_id) do
    query =
      from t in Transaction,
        where: t.from_user == ^user_id,
        select: fragment("sum(?)", t.amount)

    case Repo.one(query) do
      nil -> 0
      outcome_amount -> outcome_amount
    end
  end

  defp handle_transaction_result({:error, %Error{} = error}), do: error
  defp handle_transaction_result({:ok, result}), do: result
end
