defmodule Monex.Users.Create do
  alias Ecto.Changeset

  alias Monex.{AuthGuardian, Error, Repo, User}

  @doc """
  create/1

  Create a User

  ## Params
  - attrs: map that has user attributes valid for the creation
    - name: the name of the user
    - cpf: the user cpf identifier
    - initial_amount: the initial amount of the user
    - password: the user password

  ## Example
      iex> Monex.Users.Create.call(%{
      ..    "name" => "Batata",
      ..    "cpf" => "00000000000",
      ..    "initial_amount" => 5000,
      ..    "password" => "123456"
      ..   })

      {:ok, %Monex.User{...}, _access_token}
  """
  @spec call(map()) :: {:ok, User.t(), String.t()} | Error.t()

  def call(params) do
    params
    |> User.changeset()
    |> Repo.insert()
    |> handle_insert()
  end

  defp handle_insert({:error, %Changeset{} = changeset}), do: Error.build(:bad_request, changeset)

  defp handle_insert({:ok, %User{id: id} = user}) do
    {:ok, token, _data} = AuthGuardian.encode_and_sign(%{id: id}, %{}, ttl: {24, :hour})

    {:ok, user, token}
  end
end
