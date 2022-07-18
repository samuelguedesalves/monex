defmodule Monex.AuthGuardian do
  use Guardian, otp_app: :monex

  alias Monex.Users

  def subject_for_token(%{id: id}, _claims), do: {:ok, id}
  def subject_for_token(_, _), do: {:error, :reason_for_error}

  def resource_from_claims(%{"sub" => id}), do: Users.Get.by_id(id)
  def resource_from_claims(_claims), do: {:error, :reason_for_error}
end
