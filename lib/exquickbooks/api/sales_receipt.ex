defmodule ExQuickBooks.API.SalesReceipt do
  @moduledoc """
  Functions for interacting with the SalesReceipt API.

  This module directly implements operations from the official API:
  <https://developer.intuit.com/docs/api/accounting/salesreceipt>
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.accounting_api()
  use ExQuickBooks.Endpoint.JSON

  alias ExQuickBooks.OAuth.Credentials

  @doc """
  Creates an Sales Receipt.

  A SalesReceipt object must have at least one line that describes an item
  and an amount.
  """
  @spec create_sales_receipt(Credentials.t(), json_map) ::
          {:ok, json_map} | {:error, any}
  def create_sales_receipt(credentials, sales_receipt) do
    credentials
    |> make_request(:post, "salesreceipt", sales_receipt)
    |> sign_request(credentials)
    |> send_json_request
  end

  @doc """
  Retrieves a Sales Receipt.
  """
  @spec read_sales_receipt(Credentials.t(), String.t()) ::
          {:ok, json_map} | {:error, any}
  def read_sales_receipt(credentials, sales_receipt_id) do
    credentials
    |> make_request(:get, "salesreceipt/#{sales_receipt_id}")
    |> sign_request(credentials)
    |> send_json_request
  end

  @doc """
  Void a Sales Receipt. Must include Sparse, Id, and SyncToken as
  sales_receipt attributes.
  """
  @spec void_sales_receipt(Credentials.t(), json_map) ::
          {:ok, json_map} | {:error, any}
  def void_sales_receipt(credentials, sales_receipt) do
    credentials
    |> make_request(:post, "salesreceipt", sales_receipt, nil,
      params: [
        {"include", "void"}
      ]
    )
    |> sign_request(credentials)
    |> send_json_request
  end
end
