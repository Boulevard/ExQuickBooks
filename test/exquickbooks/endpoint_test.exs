defmodule ExQuickBooks.EndpointTest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase
  use ExQuickBooks.Endpoint, base_url: "http://localhost/"

  alias ExQuickBooks.Request
  alias ExQuickBooks.Token

  doctest ExQuickBooks.Endpoint

  test "request/5 creates a request with a base URL" do
    assert %Request{url: "http://localhost/" <> _} = request(:get, "foo")
  end

  test "sign_request/1 signs with consumer credentials" do
    assert %Request{
      headers: [{"Authorization", "OAuth " <> authorization}]
    } = request(:get, "foo") |> sign_request

    assert String.contains?(authorization, "oauth_consumer_key")
    refute String.contains?(authorization, "oauth_token")
  end

  test "sign_request/3 signs with consumer credentials and the token" do
    token = %Token{token: "token", token_secret: "secret"}

    assert %Request{
      headers: [{"Authorization", "OAuth " <> authorization}]
    } = request(:get, "foo") |> sign_request(token)

    assert String.contains?(authorization, "oauth_consumer_key")
    assert String.contains?(authorization, "oauth_token")
  end

  test "send_request/1 sends the request" do
    request = request(:get, "foo")

    send_request(request)

    assert take_request() == request
  end

  test "send_request/1 returns :ok for 2xx statuses" do
    http_200_response() |> send_response
    assert {:ok, _} = request(:get, "foo") |> send_request
  end

  test "send_request/1 returns :error for non-2xx statuses" do
    http_400_response() |> send_response
    assert {:error, _} = request(:get, "foo") |> send_request
  end
end
