defmodule ExQuickBooks.OAuth do
  @moduledoc """
  Authentication functions for OAuth 1.0a.

  QuickBooks uses the three-legged OAuth 1.0a flow. For a human-readable
  overview of the whole flow and how to implement it, see e.g.
  [oauthbible.com](http://oauthbible.com/#oauth-10a-three-legged).

  ## Request token

  To start the authentication flow, your application needs to get a request
  token using `get_request_token/0`:

  ```
  {:ok, request_token, redirect_url} = ExQuickBooks.get_request_token
  ```

  The token is an `ExQuickBooks.Token`, see its documentation for more details.

  You will also receive a URL where you should redirect the user to authorise
  your application to access their QuickBooks data. After that step they are
  redirected to the `:callback_url` you’ve set in the configuration.

  If you need to persist data (such as the request token) between this request
  and the callback, you could store that data e.g. in the current user’s
  (encrypted) session.

  ## Callback

  After authorisation, the user is redirected to your callback URL with these
  request parameters:

  - `"realmId"` -
    ID of the user’s QuickBooks realm. Note the camel-cased name.
  - `"oauth_verifier"` -
    Token verifier string you can use to retrieve an access token.

  There are more parameters as well, but these are most relevant.

  ## Access token

  You can now exchange the request token and the verifier from the callback
  request parameters for an access token using `get_access_token/2`:

  ```
  {:ok, access_token} = ExQuickBooks.get_access_token(request_token, verifier)
  ```

  The token is an `ExQuickBooks.Token`, see its documentation for more details.

  Now you should store the realm ID and access token. Use them in API calls to
  authenticate on behalf of the user.
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.oauth_api

  alias ExQuickBooks.Token

  @doc """
  Retrieves a new request token.

  Returns the request token and a URL where your application should redirect
  the user. Note that the redirect URL is already prepopulated with the request
  token.
  """
  @spec get_request_token :: {:ok, Token.t, String.t} | {:error, any}
  def get_request_token do
    result =
      request(:post, "get_request_token", nil, nil, params: [
        {"oauth_callback", ExQuickBooks.callback_url}
      ])
      |> sign_request
      |> send_request

    with {:ok, response}  <- result,
         {:ok, body}      <- parse_body(response),
         {:ok, token}     <- parse_token(body),
     do: {:ok, token, redirect_url(token)}
  end

  @doc """
  Exchanges a request token and a token verifier for an access token.

  You should have previously received the token verifier in the callback URL
  params as `"oauth_verifier"`.
  """
  @spec get_access_token(Token.t, String.t) :: {:ok, Token.t} | {:error, any}
  def get_access_token(request_token = %Token{}, verifier) do
    result =
      request(:post, "get_access_token", nil, nil, params: [
        {"oauth_token", request_token.token},
        {"oauth_verifier", verifier}
      ])
      |> sign_request(request_token)
      |> send_request

    with {:ok, response}  <- result,
         {:ok, body}      <- parse_body(response),
         {:ok, token}     <- parse_token(body),
     do: {:ok, token}
  end

  defp parse_body(%{body: body}) when is_binary(body) do
    {:ok, URI.decode_query(body)}
  end
  defp parse_body(_) do
    {:error, "Response body was malformed."}
  end

  defp parse_token(%{"oauth_token" => token, "oauth_token_secret" => secret}) do
    {:ok, %Token{token: token, token_secret: secret}}
  end
  defp parse_token(body = %{"oauth_problem" => _}) do
    {:error, body}
  end
  defp parse_token(_) do
    {:error, "Response body did not contain oauth_token or oauth_problem."}
  end

  defp redirect_url(%Token{token: token}) do
    "https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token}"
  end
end
