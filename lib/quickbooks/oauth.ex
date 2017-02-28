defmodule QuickBooks.OAuth do
  @moduledoc """
  QuickBooks OAuth API.
  """

  alias QuickBooks.OAuthEndpoint, as: Endpoint

  @doc """
  Retrieves a new OAuth request token.
  """
  def get_request_token do
    options = [params: [{"oauth_callback", QuickBooks.callback_url}]]

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

  defp parse_token_response(%{"oauth_token" => token} = body) do
    {:ok, body, redirect_url(token)}
  end
  defp parse_token_response(%{"oauth_problem" => _} = body) do
    {:error, body}
  end
  defp parse_token_response(_) do
    {:error, "Response body did not contain oauth_token or oauth_problem."}
  end

  defp redirect_url(token) do
    "https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token}"
  end
end
