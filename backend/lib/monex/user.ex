defmodule Monex.User do
  use Ecto.Schema

  import Ecto.Changeset
  alias Ecto.Changeset

  @required_params [:name, :cpf, :initial_amount, :password]

  @derive {Jason.Encoder, except: [:__meta__, :password, :password_hash]}
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :name, :string
    field :cpf, :string
    field :initial_amount, :integer
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc """
  User creation changeset

  ## Params
    - attrs : map that should has attributes necessary to create a new user
      - name : user name
      - cpf: user cpf
      - initial_amount: initial user amount
      - password : user password

  ## Example

      iex> user_attrs = %{
          name: "samuel",
          cpf: "27024081171",
          initial_amount: 200000,
          password: "123456"
        }
      iex> Monex.User.changeset(user_attrs)

      %Ecto.Changeset{changes: %{}, valid?: true}
      # or
      %Ecto.Changeset{valid?: false, errors: [...]}

  """
  @spec changeset(map()) :: Changeset.t()

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
    |> validate_length(:cpf, is: 11)
    |> validate_length(:password, min: 6)
    |> validate_cpf()
    |> unique_constraint([:cpf])
    |> check_constraint(:initial_amount,
      name: :initial_amount,
      message: "initial_amount should be positive"
    )
    |> put_password_hash()
  end

  defp put_password_hash(%Changeset{changes: %{password: password}, valid?: true} = changeset) do
    change(changeset, Pbkdf2.add_hash(password))
  end

  defp put_password_hash(%Changeset{} = changeset), do: changeset

  defp validate_cpf(%Changeset{changes: %{cpf: cpf}, valid?: true} = changeset) do
    if Brcpfcnpj.cpf_valid?(cpf),
      do: changeset,
      else: add_error(changeset, :cpf, "cpf sould be valid")
  end

  defp validate_cpf(%Changeset{} = changeset), do: changeset
end
