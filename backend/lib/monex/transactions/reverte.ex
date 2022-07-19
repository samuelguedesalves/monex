defmodule Monex.Transactions.Reverte do
  alias Ecto.UUID
  alias Monex.{Error, Repo, Transaction}

  @doc """
  call/2

  Reverte a transaction

  ## Params
  - transaction_id: the uuid that represent the transaction identifier
  - user_id: the uuid that represent the user owner identifier

  ## Example

      iex> Monex.Transactions.Reverte.call(
      ..    "1819b...",
      ..    "f2a2d..."
      ..  )

      :ok
      # or
      %Monex.Error{}
  """
  @spec call(transaction_id :: UUID.t(), user_id :: UUID.t()) :: :ok | Error.t()

  def call(transaction_id, user_id) do
    Repo.transaction(fn ->
      Repo.get(Transaction, transaction_id)
      |> cast_transaction_owner(user_id)
      |> cast_transaction_duplicity()
      |> build_params()
      |> reverte_transaction()
    end)
    |> case do
      {:ok, {:ok, %Transaction{}} = result} -> result
      {:ok, {:error, reason}} -> Error.build(:bad_request, reason)
    end
  end

  defp cast_transaction_owner(%Transaction{to_user: to_user} = transaction, user_id) do
    if user_id == to_user,
      do: {:ok, transaction},
      else: {:error, "invalid transaction owner"}
  end

  defp cast_transaction_owner(nil, _user_id) do
    {:error, "transaction not found"}
  end

  defp cast_transaction_duplicity({:ok, %Transaction{id: id}} = result) do
    case Repo.get_by(Transaction, old_transaction: id) do
      nil -> result
      %Transaction{} -> {:error, "transaction aready reverted"}
    end
  end

  defp cast_transaction_duplicity({:error, _reason} = result), do: result

  defp build_params({:ok, %Transaction{} = transaction}) do
    params = %{
      amount: transaction.amount,
      from_user: transaction.to_user,
      to_user: transaction.from_user,
      old_transaction: transaction.id
    }

    {:ok, params}
  end

  defp build_params({:error, _reason} = result), do: result

  defp reverte_transaction({:ok, params}) do
    params
    |> Transaction.changeset()
    |> Repo.insert()
  end

  defp reverte_transaction({:error, _reason} = result), do: result
end
