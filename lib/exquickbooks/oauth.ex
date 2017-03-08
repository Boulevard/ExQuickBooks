defmodule ExQuickBooks.OAuth do
  @moduledoc """
  Authentication functions for OAuth 1.0a.

  QuickBooks uses the three-legged OAuth 1.0a flow. For a human-readable
  overview of the whole flow and how to implement it, see e.g.
  [oauthbible.com](http://oauthbible.com/#oauth-10a-three-legged).

  ## Request token

  To start the authentication flow, your application needs to get a request
  token and secret using `get_request_token/0`:

  ```
  {:ok,
   %{"oauth_token" => request_token,
     "oauth_token_secret" => request_token_secret},
   redirect_url} = ExQuickBooks.get_request_token
  ```

  That function will also give you the URL where you should redirect the user
  to authorise your application to access their QuickBooks data. After that
  step they will be redirected to the `:callback_url` you’ve set in the
  configuration.

  If you need to persist data (such as the request token and secret) between
  this request and the callback, you could store that data e.g. in the current
  user’s (encrypted!) session.

  ## Callback

  After authorisation, the user is redirected to your callback URL with these
  request parameters:

  - `"realmId"` -
    ID of the user’s QuickBooks realm. Note the camel-cased name.
  - `"oauth_verifier"` -
    Verification string you can use to retrieve access credentials.

  ## Access token

  You can pass the verifier with the previous request token to
  `get_access_token/3` in order to retrieve an access token and secret:

  ```
  {:ok,
   %{"oauth_token" => access_token,
     "oauth_token_secret" => access_token_secret}} =
   ExQuickBooks.get_access_token(request_token, request_token_secret, verifier)
  ```

  Your application should now store the realm ID, access token, and secret. Use
  them in API calls to authenticate on behalf of the user.
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.oauth_api

  @type response_body :: %{required(String.t) => String.t}

  @doc """
  Retrieves a new OAuth request token.

  Returns the token response and a URL where your application should redirect
  the user.

  The response body contains the following keys:

  - `"oauth_token"` -
    The request token associated with the user.
  - `"oauth_token_secret"` -
    The request token secret associated with the user.

  Note that the redirect URL is prepopulated with the request token.
  """
  @spec get_request_token :: {:ok, response_body, String.t} | {:error, any}
  def get_request_token do
    result =
      request(:post, "get_request_token", nil, nil, params: [
        {"oauth_callback", ExQuickBooks.callback_url}
      ])
      |> sign_request()
      |> send_request

    with {:ok, response}  <- result,
         {:ok, body}      <- parse_body(response),
         {:ok, body}      <- parse_token_response(body),
     do: {:ok, body, redirect_url(body)}
  end

  @doc """
  Exchanges an authorised request token and a token verifier for an access
  token. The secret is used for signing the request.

  The token verifier required with this call was returned previously with the
  callback URL params.

  The response body contains the following keys:

  - `"oauth_token"` -
    The access token associated with the user.
  - `"oauth_token_secret"` -
    The access token secret associated with the user.
  """
  @spec get_access_token(String.t, String.t, String.t) ::
    {:ok, response_body} | {:error, any}
  def get_access_token(request_token, request_token_secret, verifier) do
    result =
      request(:post, "get_access_token", nil, nil, params: [
        {"oauth_token", request_token},
        {"oauth_verifier", verifier}
      ])
      |> sign_request(request_token, request_token_secret)
      |> send_request

    with {:ok, response}  <- result,
         {:ok, body}      <- parse_body(response),
         {:ok, body}      <- parse_token_response(body),
     do: {:ok, body}
  end

  defp parse_body(%{body: body}) when is_binary(body) do
    {:ok, URI.decode_query(body)}
  end
  defp parse_body(_) do
    {:error, "Response body was malformed."}
  end

  defp parse_token_response(body = %{"oauth_token" => _}) do
    {:ok, body}
  end
  defp parse_token_response(body = %{"oauth_problem" => _}) do
    {:error, body}
  end
  defp parse_token_response(_) do
    {:error, "Response body did not contain oauth_token or oauth_problem."}
  end

  defp redirect_url(%{"oauth_token" => token}) do
    "https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token}"
  end
end
