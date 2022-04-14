defmodule ExQuickBooks.API.Preferences do
  @moduledoc """
  Functions for interacting with the Preferences API.

  This module directly implements operations from the official API:
  <https://developer.intuit.com/v2/docs/api/accounting/preferences>
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.accounting_api()
  use ExQuickBooks.Endpoint.JSON

  alias ExQuickBooks.OAuth.Credentials

  @doc """
  Retrieves preferences for the realm.
  """
  @spec read_preferences(Credentials.t()) ::
          {:ok, json_map} | {:error, any}
  def read_preferences(credentials) do
    credentials
    |> make_request(:get, "preferences")
    |> sign_request(credentials)
    |> send_json_request
  end

  @doc """
  Updates and retrieves preferences for the realm.

  This operation performs a full update. The preferences map must define all of
  the keys in the full preferences map returned by `read_preferences/1`,
  otherwise the omitted values are set to their default values or NULL.
  """
  @spec update_preferences(Credentials.t(), json_map) ::
          {:ok, json_map} | {:error, any}
  def update_preferences(credentials, preferences) do
    credentials
    |> make_request(:post, "preferences", preferences)
    |> sign_request(credentials)
    |> send_json_request
  end
end
