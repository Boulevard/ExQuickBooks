defmodule ExQuickBooks.RequestToken do
  @moduledoc """
  OAuth 1.0a token/secret pair for requesting an access token.

  See `ExQuickBooks.OAuth` for documentation on how to obtain these tokens.

  ## Structure

  The token is technically a public/private key pair:

  - `:token` -
    The public key binary.
  - `:token_secret` -
    The private key binary.
  - `:redirect_url` -
    URL where you should redirect the user to continue authentication.

  The token is sent with API requests, but the secret is only used to calculate
  the request signatures.

  ## Storing the token

  You can store this token in the user’s session until the OAuth callback. Make
  sure the session storage is encrypted.
  """

  @type t :: %__MODULE__{
    token: binary,
    token_secret: binary,
    redirect_url: binary
  }

  @enforce_keys [
    :token,
    :token_secret,
    :redirect_url
  ]

  defstruct @enforce_keys
end
