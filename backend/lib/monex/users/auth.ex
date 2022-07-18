defmodule Monex.Users.Auth do
  alias Monex.{AuthGuardian, Error, User, Users}

  @doc """
  call/1

  Authenticate user

  ## Params
  - attrs: map that has authentication attributes
    - cpf: the user cpf identifier
    - password: the user password

  ## Example

      iex> Monex.Users.Auth.call(%{
      ..    cpf: "00000000000",
      ..    password: "123456"
      ..   })

      {:ok %{user: %Monex.User{}, token: _access_token}}
      # or
      Monex.Error{}
  """
  @spec call(map()) :: {:ok, %{user: User.t(), token: String.t()}} | Error.t()

  def call(%{cpf: cpf, password: password} = _attrs) do
    with {:ok, %User{id: id, password_hash: password_hash} = user} <- Users.Get.by_cpf(cpf),
         :ok <- verify_password(password, password_hash) do
      {:ok, token, _data} = AuthGuardian.encode_and_sign(%{id: id}, %{}, ttl: {24, :hour})

      {:ok, %{user: user, token: token}}
    end
  end

  def call(_params), do: Error.build(:bad_request, "params are missing")

  defp verify_password(password, password_hash) do
    if Pbkdf2.verify_pass(password, password_hash),
      do: :ok,
      else: Error.build(:bad_request, "invalid password")
  end
end
