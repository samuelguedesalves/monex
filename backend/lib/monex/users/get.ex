defmodule Monex.Users.Get do
  alias Monex.{Error, Repo, User}

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
    case Repo.get(User, id) do
      nil -> Error.build(:not_found, "user is not found")
      user -> {:ok, user}
    end
  end

  defp validate_cpf(cpf) do
    if Brcpfcnpj.cpf_valid?(cpf),
      do: {:ok, cpf},
      else: {:error, "cpf should be valid"}
  end

  defp get({:ok, cpf}) do
    query = from u in User, where: u.cpf == ^cpf

    case Repo.one(query) do
      nil -> Error.build(:not_found, "user is not found")
      user -> {:ok, user}
    end
  end

  defp get({:error, reason}) do
    Error.build(:bad_request, reason)
  end
end
