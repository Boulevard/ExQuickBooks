defmodule ExQuickBooks.EndpointTest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase
  use ExQuickBooks.Endpoint, base_url: "http://localhost/"

  alias ExQuickBooks.OAuth.Credentials
  alias ExQuickBooks.Request

  doctest ExQuickBooks.Endpoint

  test "request/5 creates a request with a base URL" do
    assert %Request{url: "http://localhost/" <> _} = request(:get, "foo")
  end

  test "sign_request/2 signs with consumer credentials and an access token" do
    access_token = "some-random-token"

    credentials = %Credentials{
      token: access_token,
      realm_id: "realm_id"
    }

    assert %Request{
             headers: [{"Authorization", "Bearer " <> ^access_token}]
           } = request(:get, "foo") |> sign_request(credentials)
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
