# defmodule Example do
#   use CacheMe
#   @url_env "MY_AUTH_URL"
#   @url_default "https://example.com/"

#   # No args defaults to compiled
#   @cache
#   def token, do: System.get_env("MY_AUTH_TOKEN")

#   @cache
#   @spec url :: URI.t
#   def url do
#     url = System.get_env(@url_env)

#     if is_binary(url) do
#       URI.parse(url)
#     else
#       Logger.warn("`#{@url_env}` not set, defaulting to: '#{@default}'.")
#       URI.parse(@default)
#     end
#   end

#   # Args defaults to ets
#   @cache
#   def lookup(id)

#   @cache mechanic: :compile
#   def limited(x)

#   @cache only: &(not is_nil(&1))
#   @cache only: &match({:ok, _}, &1)

#   @cache ttl: 5_000
#   def key do
#     # Generate key
#   end
# end
