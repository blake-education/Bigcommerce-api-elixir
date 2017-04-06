defmodule Bigcommerce.Client.Requester do

  def request(method, url, username, key, headers, ctype, body) do
    url = String.to_char_list(url)
    headers = [auth_header(username, key), accept_header() | headers]
    case method do
      :get ->
        :httpc.request(:get, {url, headers}, [], [])
      method ->
        headers = [{'Content-Type', ctype} | headers]
        :httpc.request(method, {url, headers, ctype, body}, [], body_format: :binary)
    end
    |> parse_response

  end

  defp accept_header, do: {'Accept', 'application/json'}

  defp auth_header(username, key) do
    {'Authorization', 'Basic ' ++ String.to_char_list(Base.encode64(username <> ":" <> key))}
  end

  defp parse_response(response) do
    case response do
      {:ok, {{_httpvs, 200, _status_phrase}, json_body}} ->
        {:ok, Poison.decode!(json_body)}
      {:ok, {{_httpvs, 201, _status_phrase}, json_body}} ->
        {:ok, Poison.decode!(json_body)}
      {:ok, {{_httpvs, 200, _status_phrase}, _headers, json_body}} ->
        {:ok, Poison.decode!(json_body)}
      {:ok, {{_httpvs, 201, _status_phrase}, _headers, json_body}} ->
        {:ok, Poison.decode!(json_body)}
      {:ok, {{_httpvs, 204, _status_phrase}, _headers, _empty_body}} ->
        {:ok, []}
      {:ok, {{_httpvs, status, _status_phrase}, json_body}} ->
        {:error, status, Poison.decode!(json_body)}
      {:ok, {{_httpvs, status, _status_phrase}, _headers, json_body}} ->
        {:error, status, Poison.decode!(json_body)}
      {:error, reason} ->
        {:error, :bad_fetch, reason}
    end
  end

end
