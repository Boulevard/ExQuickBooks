defmodule ExQuickBooks.OAuth do
  @moduledoc """
  Authentication functions for OAuth 1.0a.

  QuickBooks uses the three-legged OAuth 1.0a flow. For a human-readable
  overview of the whole flow and how to implement it, see e.g.
  [oauthbible.com](http://oauthbible.com/#oauth-10a-three-legged).

  ## Request token

  To start the authentication flow, your application needs to get a request
  token and secret using `get_request_token/0`:

      {:ok,
       %{"oauth_token" => oauth_token,
         "oauth_token_secret" => oauth_token_secret},
       redirect_url} = ExQuickBooks.get_request_token

  That function will also give you the URL where you should redirect the user
  to authorise your application to access their QuickBooks data. After that
  step they will be redirected to the `:callback_url` you’ve set in the
  configuration.

  If you need to persist data (such as the request token and secret) between
  this request and the callback, you could store that data e.g. in the current
  user’s (encrypted!) session.
  """

  alias ExQuickBooks.OAuthEndpoint, as: Endpoint

  @doc """
  Retrieves a new OAuth request token.

  Returns the token response and a URL where your application should redirect
  the user. The token response contains the following keys:

  - `"oauth_token"` -
    The token associated with the user.
  - `"oauth_token_secret"` -
    The token secret associated with the user.

  Note that the redirect URL is prepopulated with the token.
  """
  @type request_token     :: %{required(String.t) => String.t}
  @type redirect_url      :: String.t
  @spec get_request_token :: {:ok, request_token, redirect_url} | {:error, any}
  def get_request_token do
    options = [params: [{"oauth_callback", ExQuickBooks.callback_url}]]

    with {:ok, response}  <- Endpoint.post("get_request_token", "", [], options),
         {:ok, body}      <- parse_body(response),
         {:ok, body, url} <- parse_token_response(body),
     do: {:ok, body, url}
  end

  defp parse_body(%{body: body}) when is_binary(body) do
    {:ok, URI.decode_query(body)}
  end
  defp parse_body(_) do
    {:error, "Response body was malformed."}
  end

  defp parse_token_response(body = %{"oauth_token" => token}) do
    {:ok, body, redirect_url(token)}
  end
  defp parse_token_response(body = %{"oauth_problem" => _}) do
    {:error, body}
  end
  defp parse_token_response(_) do
    {:error, "Response body did not contain oauth_token or oauth_problem."}
  end

  defp redirect_url(token) do
    "https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token}"
  end
end
