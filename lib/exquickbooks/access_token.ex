defmodule ExQuickBooks.AccessToken do
  @moduledoc """
  OAuth 1.0a token/secret pair for authenticating API calls.

  See `ExQuickBooks.OAuth` for documentation on how to obtain these tokens.

  ## Structure

  The token is technically a public/private key pair:

  - `:token` -
    The public key binary.
  - `:token_secret` -
    The private key binary.
  - `:realm_id` -
    ID of the Realm this token is associated with.

  The token is sent with API requests, but the secret is only used to calculate
  the request signatures.

  ## Storing the token

  You can store the token as is if your storage supports maps (in a Postgres
  `jsonb` column, for example) or store the keys individually.
  """

  @type t :: %__MODULE__{
    token: binary,
    token_secret: binary,
    realm_id: binary
  }

  @enforce_keys [
    :token,
    :token_secret,
    :realm_id
  ]

  defstruct @enforce_keys
end
