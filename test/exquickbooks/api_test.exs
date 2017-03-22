defmodule ExQuickBooks.APITest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase

  alias ExQuickBooks.API
  alias ExQuickBooks.OAuth.AccessToken

  doctest API

  @token %AccessToken{
    token: "token",
    token_secret: "secret",
    realm_id: "realm_id"
  }

  test "query/2 retrieves a query response" do
    load_response("api/query.json") |> send_response

    assert {:ok, %{"QueryResponse" => _}} =
      API.query(@token, "SELECT * FROM Item")

    assert %{
      url: url,
      headers: headers,
      options: [params: params]
    } = take_request()

    assert String.contains?(url, "/query")

    assert {"Accept", "application/json"} in headers
    assert {"Content-Type", "text/plain"} in headers

    assert {"query", "SELECT * FROM Item"} in params
  end

  test "query/2 recovers from an error" do
    load_response("api/query_error.json")
    |> Map.put(:status_code, 400)
    |> send_response

    assert {:error, %{"Fault" => _}} =
      API.query(@token, "SELECT * FROM NULL")
  end
end
