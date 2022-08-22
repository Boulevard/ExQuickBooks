defmodule ExQuickBooks.API.Batch do
  @moduledoc """
  Functions for interacting with the Batch API.

  This module directly implements operations from the official API:
  <https://developer.intuit.com/app/developer/qbo/docs/api/accounting/all-entities/batch>
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.accounting_api()
  use ExQuickBooks.Endpoint.JSON

  alias ExQuickBooks.OAuth.Credentials

  @doc """
  Performs the given query operations in a single request
  """
  @spec read_batch(Credentials.t(), list(%{bId: String.t(), Query: String.t()}), keyword()) ::
          {:ok, json_map} | {:error, any}
  def read_batch(credentials, queries, opts \\ []) do
    credentials
    |> make_request(:post, "batch", Jason.encode!(%{BatchItemRequest: queries}), nil, opts)
    |> sign_request(credentials)
    |> send_json_request()
  end
end
