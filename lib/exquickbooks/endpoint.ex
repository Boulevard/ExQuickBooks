defmodule ExQuickBooks.Endpoint do
  @moduledoc false

  alias ExQuickBooks.Request
  alias ExQuickBooks.OAuth.Credentials
  alias HTTPoison.Response

  @default_using_options [base_url: ""]

  defmacro __using__(using_options \\ []) do
    merged_using_options = Keyword.merge(@default_using_options, using_options)

    quote do
      import unquote(__MODULE__),
        only: [
          sign_request: 2,
          send_request: 1
        ]

      @doc false
      def request(method, url, body \\ nil, headers \\ nil, options \\ nil) do
        base_url = unquote(merged_using_options)[:base_url]

        %Request{
          method: method,
          url: base_url <> url,
          body: body || "",
          headers: headers || [],
          options: options || []
        }
      end
    end
  end

  def sign_request(request = %Request{}, %Credentials{token: access_token}) do
    request_params =
      (request.options[:params] || [])
      |> append_default_minorversion()

    new_headers =
      request.headers
      |> merge_headers([{"Authorization", "Bearer #{access_token}"}])

    new_options = Keyword.put(request.options, :params, request_params)

    %{request | headers: new_headers, options: new_options}
  end

  defp append_default_minorversion(params) do
    has_minorversion =
      Enum.any?(params, fn
        {"minorversion", _} -> true
        _ -> false
      end)

    case has_minorversion do
      true -> params
      false -> [{"minorversion", ExQuickBooks.minorversion()} | params]
    end
  end

  def send_request(request = %Request{}) do
    with {:ok, response} <- ExQuickBooks.backend().request(request) do
      parse_status(response)
    end
  end

  def merge_headers(left, right) do
    # Enum.uniq_by takes the first element and discards the rest; we need to
    # preserve headers on the right side.
    Enum.uniq_by(right ++ left, fn {k, _} -> k end)
  end

  defp parse_status(response = %Response{status_code: c}) when c in 200..299 do
    {:ok, response}
  end

  defp parse_status(response = %Response{}) do
    {:error, response}
  end
end
