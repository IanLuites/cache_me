defmodule CacheMe.AST do
  @moduledoc false

  def attributes(module, code) do
    fetch = &Module.get_attribute(module, &1)

    code
    |> Macro.postwalk(%{}, fn
      c = {:@, _, [{name, _, nil}]}, acc -> {c, Map.put(acc, name, fetch.(name))}
      c, acc -> {c, acc}
    end)
    |> elem(1)
  end

  def arity(args) do
    Enum.reduce(args, 0..0, fn
      {:\\, _, _}, min..max -> min..(max + 1)
      _, min..max -> (min + 1)..(max + 1)
    end)
  end

  def strip_defaults(args) do
    Enum.map(args, fn
      {:\\, _, [arg, _]} -> arg
      arg -> arg
    end)
  end
end
