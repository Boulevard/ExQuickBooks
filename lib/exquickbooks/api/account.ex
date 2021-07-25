defmodule ExQuickBooks.API.Account do
  @moduledoc """
  Functions for interacting with the Account API.

  This module directly implements operations from the official API:
  <https://developer.intuit.com/app/developer/qbo/docs/api/accounting/all-entities/account>
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.accounting_api()
  use ExQuickBooks.Endpoint.JSON

  alias ExQuickBooks.OAuth.Credentials

  @doc """
  Retrieves an account.
  """
  @spec read_account(Credentials.t(), String.t()) ::
          {:ok, json_map} | {:error, any}
  def read_account(credentials, account_id) do
    request(:get, "company/#{credentials.realm_id}/account/#{account_id}")
    |> sign_request(credentials)
    |> send_json_request()
  end
end
