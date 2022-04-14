defmodule ExQuickBooks.API.CompanyInfo do
  @moduledoc """
  Functions for interacting with the CompanyInfo API.

  This module directly implements operations from the official API:
  <https://developer.intuit.com/app/developer/qbo/docs/api/accounting/all-entities/companyinfo>
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.accounting_api()
  use ExQuickBooks.Endpoint.JSON

  alias ExQuickBooks.OAuth.Credentials

  @doc """
  Retrieves company info.
  """
  @spec read_company_info(Credentials.t()) ::
          {:ok, json_map} | {:error, any}
  def read_company_info(credentials) do
    credentials
    |> make_request(:get, "companyinfo/#{credentials.realm_id}")
    |> sign_request(credentials)
    |> send_json_request()
  end
end
