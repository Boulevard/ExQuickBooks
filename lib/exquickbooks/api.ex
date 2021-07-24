defmodule ExQuickBooks.API do
  @moduledoc """
  Functions for interacting with the API.

  This module directly implements operations from the official API:
  <https://developer.intuit.com/v2/docs/api/accounting>
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.accounting_api()
  use ExQuickBooks.Endpoint.JSON

  alias ExQuickBooks.OAuth.AccessToken

  @doc """
  Retrieves multiple entities using a SQL-like query.

  See the [query documentation][0] for more details.

  [0]: https://developer.intuit.com/docs/0100_quickbooks_online/0300_references/0000_programming_guide/0050_data_queries
  """
  @spec query(AccessToken.t(), String.t()) :: {:ok, json_map} | {:error, any}
  def query(token, query) do
    headers = [{"Content-Type", "text/plain"}]
    options = [params: [{"query", query}]]

    request(:get, "company/#{token.realm_id}/query", nil, headers, options)
    |> sign_request(token)
    |> send_json_request
  end
end
