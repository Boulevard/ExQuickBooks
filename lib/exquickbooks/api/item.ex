defmodule ExQuickBooks.API.Item do
  @moduledoc """
  Functions for interacting with the Item API.

  This module directly implements operations from the official API:
  <https://developer.intuit.com/v2/docs/api/accounting/item>
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.accounting_api
  use ExQuickBooks.Endpoint.JSON

  alias ExQuickBooks.OAuth.AccessToken

  @doc """
  Creates an item.

  The item name must be unique. Sales items must define `IncomeAccountRef`.
  Purchase items must define `ExpenseAccountRef`.
  """
  @spec create_item(AccessToken.t, json_map) ::
    {:ok, json_map} | {:error, any}
  def create_item(token, item) do
    request(:post, "company/#{token.realm_id}/item", item)
    |> sign_request(token)
    |> send_json_request
  end

  @doc """
  Retrieves an item.
  """
  @spec read_item(AccessToken.t, String.t) ::
    {:ok, json_map} | {:error, any}
  def read_item(token, item_id) do
    request(:get, "company/#{token.realm_id}/item/#{item_id}")
    |> sign_request(token)
    |> send_json_request
  end

  @doc """
  Updates and retrieves an item.

  The item map must define all of the keys in the full item map returned by
  `read_item/2`, otherwise the omitted values are set to their default values
  or NULL.
  """
  @spec update_item(AccessToken.t, json_map) ::
    {:ok, json_map} | {:error, any}
  def update_item(token, item) do
    request(:post, "company/#{token.realm_id}/item", item)
    |> sign_request(token)
    |> send_json_request
  end
end
