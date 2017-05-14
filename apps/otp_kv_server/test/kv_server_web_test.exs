defmodule KVServer.WebTest do
  use ExUnit.Case
  use Plug.Test
  @moduletag :capture_log

  alias KVServer.Web

  @opts Web.init([])

  doctest KVServer.Web

  test "returns welcome" do
    conn = conn(:get, "/", "")
      |> Web.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "API behavior" do
    bucket = "shopping"
    key = "milk"
    value = 3

    conn = conn(:post, "/buckets/create", "bucket=#{bucket}")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> Web.call(@opts)

    assert conn.resp_body == "Created bucket #{bucket}"
    assert conn.state == :sent
    assert conn.status == 200

    conn = conn(:put, "/buckets/#{bucket}/#{key}", "value=#{value}")
      |> put_req_header("content-type", "application/x-www-form-urlencoded")
      |> Web.call(@opts)

    assert conn.resp_body == "Put #{key}=#{value} in #{bucket}"
    assert conn.state == :sent
    assert conn.status == 200

    conn = conn(:get, "/buckets/#{bucket}/#{key}", "")
      |> Web.call(@opts)

    assert conn.resp_body == "#{value}"
    assert conn.state == :sent
    assert conn.status == 200

    conn = conn(:delete, "/buckets/#{bucket}/#{key}", "")
      |> Web.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200

    conn = conn(:get, "/buckets/#{bucket}/#{key}", "")
      |> Web.call(@opts)

    assert conn.state == :sent
    assert conn.status == 500
  end

  test "returns 404" do
    conn = conn(:get, "/missing", "")
      |> Web.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
