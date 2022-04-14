defmodule ExQuickBooks.API.Reports do
  @moduledoc """
  Functions for interacting with the Reports API.

  This module directly implements operations from the official API, e.g.:
  <https://developer.intuit.com/app/developer/qbo/docs/api/accounting/report-entities/profitandloss>
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.accounting_api()
  use ExQuickBooks.Endpoint.JSON

  alias ExQuickBooks.OAuth.Credentials

  @doc """
  Retrieves the given report.
  """
  @spec read_report(Credentials.t(), String.t(), %{String.t() => String.t()}) ::
          {:ok, json_map} | {:error, any}
  def read_report(credentials, report_type, options \\ %{}) do
    query = URI.encode_query(options)

    credentials
    |> make_request(:get, "reports/#{report_type}?#{query}")
    |> sign_request(credentials)
    |> send_json_request()
  end
end
