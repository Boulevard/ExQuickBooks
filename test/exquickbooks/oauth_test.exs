defmodule ExQuickBooks.OAuthTest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase

  alias ExQuickBooks.AccessToken
  alias ExQuickBooks.OAuth
  alias ExQuickBooks.RequestToken

  doctest OAuth

  @request_token %RequestToken{
    token: "token",
    token_secret: "secret",
    redirect_url: "https://appcenter.intuit.com/Connect/Begin?oauth_token=token"
  }

  @access_token %AccessToken{
    token: "token",
    token_secret: "secret",
    realm_id: "realm_id"
  }

  test "get_request_token/0 returns a request token" do
    load_response("oauth/get_request_token") |> send_response
    assert OAuth.get_request_token == {:ok, @request_token}
  end

  test "get_request_token/0 recovers when there's an OAuth problem" do
    load_response("oauth/get_request_token_problem") |> send_response

    assert OAuth.get_request_token ==
      {:error, %{"oauth_problem" => "signature_invalid"}}
  end

  test "get_request_token/0 recovers when there's some other error" do
    http_400_response() |> send_response
    assert {:error, _} = OAuth.get_request_token
  end

  test "get_access_token/3 returns an access token" do
    load_response("oauth/get_access_token") |> send_response

    assert OAuth.get_access_token(@request_token, "realm_id", "verifier") ==
      {:ok, @access_token}
  end

  test "get_access_token/3 recovers when there's an OAuth problem" do
    load_response("oauth/get_access_token_problem") |> send_response

    assert OAuth.get_access_token(@request_token, "realm_id", "verifier") ==
      {:error, %{"oauth_problem" => "signature_invalid"}}
  end

  test "get_access_token/3 recovers when there's some other error" do
    http_400_response() |> send_response

    assert {:error, _} =
      OAuth.get_access_token(@request_token, "realm_id", "verifier")
  end
end
