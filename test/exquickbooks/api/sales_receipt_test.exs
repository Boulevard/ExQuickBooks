defmodule ExQuickBooks.API.SalesReceiptTest do
  use ExUnit.Case, async: false
  use ExQuickBooks.APICase

  alias ExQuickBooks.API.SalesReceipt
  alias ExQuickBooks.OAuth.AccessToken

  doctest SalesReceipt

  @token %AccessToken{
    token: "token",
    token_secret: "secret",
    realm_id: "realm_id"
  }

  test "create_sales_receipt/3 creates an sales_receipt" do
    load_response("sales_receipt/create_sales_receipt.json") |> send_response

    assert {:ok, %{"SalesReceipt" => _}} = SalesReceipt.create_sales_receipt(@token, %{foo: true})

    assert %{body: body} = take_request()
    assert String.contains?(to_string(body), "foo")
  end

  test "create_sales_receipt/3 recovers from an error" do
    load_response("sales_receipt/create_sales_receipt_error.json")
    |> Map.put(:status_code, 400)
    |> send_response

    assert {:error, %{"Fault" => _}} = SalesReceipt.create_sales_receipt(@token, %{foo: true})
  end

  test "void_sales_receipt/3 voids and retrieves an sales_receipt" do
    load_response("sales_receipt/void_sales_receipt.json") |> send_response

    assert {:ok, %{"SalesReceipt" => _}} = SalesReceipt.void_sales_receipt(@token, %{foo: true})

    assert %{body: body} = take_request()
    assert String.contains?(to_string(body), "foo")
  end

  test "void_sales_receipt/3 recovers from an error" do
    load_response("sales_receipt/void_sales_receipt_error.json")
    |> Map.put(:status_code, 400)
    |> send_response

    assert {:error, %{"Fault" => _}} = SalesReceipt.void_sales_receipt(@token, %{foo: true})
  end
end
