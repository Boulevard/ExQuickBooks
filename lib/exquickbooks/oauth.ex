defmodule ExQuickBooks.OAuth do
  @moduledoc """
  Functions for interacting with the OAuth API.

  QuickBooks uses the three-legged OAuth 1.0a flow. For a human-readable
  overview of the whole flow and how to implement it, see e.g.
  [oauthbible.com](http://oauthbible.com/#oauth-10a-three-legged).

  ## Request token

  To start the authentication flow, your application needs to get a request
  token using `get_request_token/1`:

  ```
  {:ok, request_token} = ExQuickBooks.get_request_token(callback_url)
  ```

  The token is an `ExQuickBooks.OAuth.RequestToken`, see its documentation for
  more details.

  You should redirect the user to `request_token.redirect_url` to authorise
  your application to access their QuickBooks data. After that step they are
  redirected to the given callback URL.

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

  You can now exchange the request token, realm ID, and the verifier from the
  callback request parameters for an access token using `get_access_token/3`:

  ```
  {:ok, access_token} = ExQuickBooks.get_access_token(request_token, realm_id, verifier)
  ```

  Now you can store the access token and use it in API calls to authenticate on
  behalf of the user. The token is an `ExQuickBooks.OAuth.AccessToken`, see its
  documentation for more details.
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.oauth_api

  alias ExQuickBooks.OAuth.AccessToken
  alias ExQuickBooks.OAuth.RequestToken

  @doc """
  Retrieves a new request token.

  The callback URL must be an absolute URL where the user is redirected after
  authorising your application.

  Returns the request token with a URL where your application should redirect
  the user as `request_token.redirect_url`.
  """
  @spec get_request_token(String.t) ::
    {:ok, RequestToken.t} | {:error, any}
  def get_request_token(callback_url) do
    result =
      request(:post, "get_request_token", nil, nil, params: [
        {"oauth_callback", callback_url}
      ])
      |> sign_request
      |> send_request

    with {:ok, response}  <- result,
         {:ok, body}      <- parse_body(response),
         {:ok, token}     <- parse_token(body),
     do: {:ok, create_request_token(token)}
  end

  @doc """
  Exchanges a request token, realm ID, and token verifier for an access token.

  You should have previously received the realm ID and token verifier in the
  callback URL params as `"realmId"` and `"oauth_verifier"`.
  """
  @spec get_access_token(RequestToken.t, String.t, String.t) ::
    {:ok, AccessToken.t} | {:error, any}
  def get_access_token(request_token = %RequestToken{}, realm_id, verifier) do
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
     do: {:ok, create_access_token(token, realm_id)}
  end

  defp parse_body(%{body: body}) when is_binary(body) do
    {:ok, URI.decode_query(body)}
  end
  defp parse_body(_) do
    {:error, "Response body was malformed."}
  end

  defp parse_token(%{"oauth_token" => token, "oauth_token_secret" => secret}) do
    {:ok, %{token: token, token_secret: secret}}
  end
  defp parse_token(body = %{"oauth_problem" => _}) do
    {:error, body}
  end
  defp parse_token(_) do
    {:error, "Response body did not contain oauth_token or oauth_problem."}
  end

  defp create_request_token(token) do
    values =
      token
      |> Map.put(:redirect_url, redirect_url(token))
      |> Map.to_list

    struct!(RequestToken, values)
  end

  defp create_access_token(token, realm_id) do
    values =
      token
      |> Map.put(:realm_id, realm_id)
      |> Map.to_list

    struct!(AccessToken, values)
  end

  defp redirect_url(%{token: token}) do
    "https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token}"
  end
end
