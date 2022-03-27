defmodule CacheMeTest do
  use ExUnit.Case
  doctest CacheMe

  test "greets the world" do
    assert CacheMe.hello() == :world
  end
end
