defmodule ExQuickBooks.OAuth.Credentials do
  @moduledoc """
  Pairing of realm_id and access_token

  ## Structure

  - `:token` -
    The bearer access token.
  - `:realm_id` -
    ID of the Realm this token is associated with.

  ## Storing the token

  You can store the token as is if your storage supports maps (in a Postgres
  `jsonb` column, for example) or store the keys individually.
  """

  @type t :: %__MODULE__{
          token: String.t(),
          realm_id: String.t(),
          base_url: String.t() | nil
        }

  @enforce_keys [
    :token,
    :realm_id,
    :base_url
  ]

  defstruct @enforce_keys
end
