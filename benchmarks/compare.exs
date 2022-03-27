defmodule Compare do
  use CacheMe

  @modes ~w(http tcp mocked)a
  @default :http
  @lookup Map.new(@modes, &{to_string(&1), &1})

  def hardcoded, do: @default

  def environment do
    Map.get(@lookup, System.get_env("MODE"), @default)
  end

  def application do
    Application.get_env(:cache_me, :mode)
  end

  @cache true
  def cached do
    Map.get(@lookup, System.get_env("MODE"), @default)
  end
end

Application.put_env(:cache_me, :mode, Compare.hardcoded())

Benchee.run(
  %{
    "Hardcoded" => &Compare.hardcoded/0,
    "Environment" => &Compare.environment/0,
    "Application" => &Compare.application/0,
    "CacheMe" => &Compare.cached/0
  },
  time: 2
)
