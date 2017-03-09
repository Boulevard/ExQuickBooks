defmodule ExQuickBooks.Endpoint do
  @moduledoc false

  alias ExQuickBooks.Request

  @default_using_options [base_url: ""]

  defmacro __using__(using_options \\ []) do
    merged_using_options = Keyword.merge(@default_using_options, using_options)

    quote do
      import unquote(__MODULE__), only: [
        sign_request: 1,
        sign_request: 2,
        send_request: 1
      ]

      @doc false
      def request(method, url, body \\ nil, headers \\ nil, options \\ nil) do
        endpoint = unquote(__MODULE__)
        base_url = unquote(merged_using_options)[:base_url]

        endpoint.request(method, base_url <> url, body, headers, options)
      end
    end
  end

  def request(method, url, body, headers, options) do
    %Request{
      method: method,
      url: url,
      body: body || "",
      headers: headers || [],
      options: options || []
    }
  end

  def sign_request(request = %Request{}, token \\ %{}) do
    credentials =
      token
      |> Map.delete(:__struct__)
      |> Map.merge(ExQuickBooks.credentials)
      |> Map.to_list
      |> OAuther.credentials

    {header, new_params} =
      request.method
      |> to_string
      |> OAuther.sign(request.url, request.options[:params] || [], credentials)
      |> OAuther.header

    new_headers = [header] ++ request.headers
    new_options = Keyword.put(request.options, :params, new_params)

    %{request | headers: new_headers, options: new_options}
  end

  def send_request(request = %Request{}) do
    ExQuickBooks.backend.request(request)
  end
end
