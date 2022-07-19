defmodule Monex.Transactions.Get do
  alias Monex.{Error, Repo, Transaction}

  import Ecto.Query

  @doc """
  by_id/2

  Get a transaction by id if belongs on respective user id

  ## Params
  - transaction_id: uuid that represents the transaction identifier
  - user_id: uuid that represents the user identifier

  ## Example

      iex> Monex.Transactions.Get.call("c97c...", "7e48...")

      {:ok, %Monex.Transaction{}}
      # or
      %Monex.Error{}

  """
  @spec by_id(Ecto.UUID.t(), Ecto.UUID.t()) :: {:ok, Transaction.t()} | Error.t()

  def by_id(transaction_id, user_id) do
    query =
      from t in Transaction,
        where: t.id == ^transaction_id and (t.from_user == ^user_id or t.to_user == ^user_id)

    case Repo.one(query) do
      nil -> Error.build(:bad_request, "transaction is not found")
      transaction -> {:ok, transaction}
    end
  end

  @doc """
  by_user_id/2

  Get transactions by user id

  ## Params
  - user_id: the uuid that represents the user identifier
  - page: number that represents the pagination number

  ## Example

      iex> Monex.Transactions.by_user_id("7e48...", 1)
      {
        :ok,
        %{
          page: 1,
          transactions: [%Monex.Transaction{}],
          quantity: 1,
          next_page: 2,
        }
      }

  """
  @spec by_user_id(Ecto.UUID.t(), integer()) ::
          {:ok,
           %{
             page: integer(),
             transactions: list(Transaction.t()),
             quantity: integer(),
             next_page: integer()
           }}

  def by_user_id(user_id, page) when page <= 0, do: by_user_id(user_id, 1)

  def by_user_id(user_id, page) do
    skipe = page * 10 - 10

    query =
      from t in Transaction,
        where: t.from_user == ^user_id or t.to_user == ^user_id,
        order_by: [desc: t.processed_at],
        offset: ^skipe,
        limit: 10

    transactions = Repo.all(query)

    result = %{
      page: page,
      transactions: transactions,
      quantity: length(transactions),
      next_page: page + 1
    }

    {:ok, result}
  end
end
