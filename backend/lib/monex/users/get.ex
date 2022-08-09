defmodule Monex.Users.Get do
  alias Monex.{Error, Repo, User, Users}

  import Ecto.Query

  @doc """
  by_cpf/1

  Get user by cpf

  ## Params
  - cpf: the user cpf

  ## Example

      iex> Monex.Users.Get.by_cpf("00000000000")

      {:ok, %Monex.User{}}
      # or
      %Monex.Error{}
  """
  @spec by_cpf(String.t()) :: {:ok, User.t()} | Error.t()

  def by_cpf(cpf) do
    cpf
    |> validate_cpf()
    |> get()
  end

  @doc """
  by_id/1

  Get user by id

  ## Params
  - user_id: the uuid that represent the user identifier

  ## Example

      iex> Monex.Users.Get.by_id("71a1d351-9ce0-4f02-b8e7-7d907f2796b6")

      {:ok, %Monex.User{}}
      # or
      %Monex.Error{}
  """
  @spec by_id(Ecto.UUID.t()) :: {:ok, User.t()} | Error.t()

  def by_id(id) do
    {:ok, result} =
      Repo.transaction(fn ->
        with %User{} = user <- Repo.get(User, id),
             {:ok, %User{} = user} <- load_user_amount(user) do
          {:ok, user}
        else
          nil -> Error.build(:not_found, "user is not found")
          %Error{} = error -> error
        end
      end)

    result
  end

  defp validate_cpf(cpf) do
    if Brcpfcnpj.cpf_valid?(cpf),
      do: {:ok, cpf},
      else: {:error, "cpf should be valid"}
  end

  defp get({:ok, cpf}) do
    query = from u in User, where: u.cpf == ^cpf

    {:ok, result} =
      Repo.transaction(fn ->
        with %User{} = user <- Repo.one(query),
             {:ok, %User{} = user} <- load_user_amount(user) do
          {:ok, user}
        else
          nil -> Error.build(:not_found, "user is not found")
          %Error{} = error -> error
        end
      end)

    result
  end

  defp get({:error, reason}) do
    Error.build(:bad_request, reason)
  end

  defp load_user_amount(%User{id: user_id} = user) do
    with {:ok, user_amounts} <- Users.GetAmount.call(user_id) do
      user = Map.merge(user, user_amounts)

      {:ok, user}
    end
  end
end
