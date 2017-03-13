defmodule ExQuickBooks.Preferences do
  @moduledoc """
  Functions for interacting with the Preferences API.

  This module directly implements operations from the official API:
  <https://developer.intuit.com/v2/docs/api/accounting/preferences>
  """

  use ExQuickBooks.Endpoint, base_url: ExQuickBooks.accounting_api
  use ExQuickBooks.JSONEndpoint

  alias ExQuickBooks.Token

  @doc """
  Retrieves preferences for the given realm.
  """
  @spec read_preferences(Token.t, String.t) ::
    {:ok, json_map} | {:error, any}
  def read_preferences(token, realm_id) do
    request(:get, "company/#{realm_id}/preferences")
    |> sign_request(token)
    |> send_json_request
  end

  @doc """
  Updates and retrieves preferences for the given realm.

  This operation performs a full update. The preferences map must define all of
  the keys in the full preferences map returned by `read_preferences/2`,
  otherwise the omitted values are set to their default values or NULL.
  """
  @spec update_preferences(Token.t, String.t, json_map) ::
    {:ok, json_map} | {:error, any}
  def update_preferences(token, realm_id, preferences) do
    request(:post, "company/#{realm_id}/preferences", preferences)
    |> sign_request(token)
    |> send_json_request
  end
end
