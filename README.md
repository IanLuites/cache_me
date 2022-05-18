# CacheMe

Cache functions without hassle.

## Quick Start

Add `cache_me` to your list of dependencies in `mix.exs`:

```elixir
{:cache_me, "~> 0.0.1"}
```

Then add `use CacheMe` to any module using caching
and `@cache true` to any function you would like to cache.

Use `CacheMe.uncached(<module>, <function>, <args>)` to skip the cache.
The syntax is the same as `apply/3`.

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

16:30:03.556 [warning] `MY_AUTH_URL` not set, defaulting to: 'https://example.com/'.
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

It is possible to skip the cache using `CacheMe.uncached(<module>, <function>, <args>)`.
In this case `CacheMe.uncached(Example, :url, [])`.

Continuing from above:

```shell
iex(3)> CacheMe.uncached(Example, :url, [])

16:30:17.690 [warning] `MY_AUTH_URL` not set, defaulting to: 'https://example.com/'.
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

## Changelog

### 0.0.4 (2022-05-18)

Remove `defdelegate` from compile logic to better support `defp`.

### 0.0.3 (2022-05-16)

Relax Elixir constraints.

### 0.0.2 (2022-05-16)

Add missing `:crypto` to extra_applications.

### 0.0.1 (2022-05-12)

First basic release. [Hex](https://hex.pm/packages/cache_me/0.0.1)
