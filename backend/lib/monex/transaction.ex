defmodule Monex.Transaction do
  use Ecto.Schema

  import Ecto.Changeset

  @params [:amount, :from_user, :to_user, :old_transaction]
  @required_params @params -- [:old_transaction]

  @derive {Jason.Encoder, except: [:__meta__]}
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "transactions" do
    field :amount, :integer
    field :from_user, :binary_id
    field :to_user, :binary_id
    field :old_transaction, :binary_id

    timestamps(inserted_at: :processed_at)
  end

  @doc """
  Transaction creation changeset

  ## Params
    - params : map that should has attributes necessary to create a new user
      - amount : transaction amount
      - from_user: sender user id
      - to_user: receiver user id
      - old_transaction: when reverse a transaction, should paste here the old transaction id

  ## Example

      iex> transaction_params = %{
      ..    amount: 2000,
      ..    from_user: "f8ca7b51-46b2-45f4-912e-a7b3ac070fd2",
      ..    to_user: "a8ef26dd-4390-4e23-b8b1-2ee9d01c2803",
      ..  }

      iex> Monex.Transaction.changeset(transaction_params)

      %Ecto.Changeset{changes: %{}, valid?: true}
      # or
      %Ecto.Changeset{valid?: false, errors: [...]}

  """
  @spec changeset(map()) :: Changeset.t()

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @params)
    |> validate_required(@required_params)
    |> check_constraint(:amount, name: :amount, message: "amount should be positive")
  end
end
