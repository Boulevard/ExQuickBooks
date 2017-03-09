defmodule ExQuickBooks.Token do
  @moduledoc """
  OAuth 1.0a token/secret pair for authenticating API calls.

  See `ExQuickBooks.OAuth` for documentation on how to obtain these tokens.

  ## Structure

  The token is technically a public/private key pair:

  - `:token` - The public key binary.
  - `:token_secret` - The private key binary.

  The token is sent with API requests, but the secret is only used to calculate
  the request signatures.

  ## Storing the token

  You can store the token as is if your storage supports maps (in a Postgres
  `jsonb` column, for example) or store the keys individually.

  If you’re storing the token in a user’s session, make sure the session
  storage is encrypted.
  """

  @type t :: %__MODULE__{
    token: binary,
    token_secret: binary
  }

  @enforce_keys [
    :token,
    :token_secret
  ]

  defstruct @enforce_keys
end
