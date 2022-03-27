# CacheMe

Cache functions without hassle.

## Quick Start

Add `cache_me` to your list of dependencies in `mix.exs`:

```elixir
{:cache_me, "~> 0.0.1"}
```

Then add `use CacheMe` to any module using caching
and `@cache true` to any function you would like to cache.

## Example

```elixir
defmodule Example do
  use CacheMe
  require Logger

  @url_env "MY_AUTH_URL"
  @url_default "https://example.com/"

  @cache true
  @spec url :: URI.t()
  def url do
    url = System.get_env(@url_env)

    if is_binary(url) do
      URI.parse(url)
    else
      Logger.warn("`#{@url_env}` not set, defaulting to: '#{@url_default}'.")
      URI.parse(@url_default)
    end
  end
end
```

Use:

```shell
iex(1)> Example.url

23:17:20.556 [warning] `MY_AUTH_URL` not set, defaulting to: 'https://example.com/'.
%URI{
  authority: "example.com",
  fragment: nil,
  host: "example.com",
  path: "/",
  port: 443,
  query: nil,
  scheme: "https",
  userinfo: nil
}
iex(2)> Example.url
%URI{
  authority: "example.com",
  fragment: nil,
  host: "example.com",
  path: "/",
  port: 443,
  query: nil,
  scheme: "https",
  userinfo: nil
}
```

The `Example.url/0` logic is only executed once.

## Changelog

### 0.0.1 (2022-05-12)

First release for testing.
