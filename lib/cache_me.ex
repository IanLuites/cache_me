defmodule CacheMe do
  @moduledoc File.read!(Path.expand("../README.md", __DIR__))

  @doc false
  @spec purge(module) :: :ok
  def purge(module)
  def purge(_), do: :ok

  @doc false
  @spec purge(module :: module, function :: atom, arity :: non_neg_integer()) :: :ok
  def purge(module, function, arity)
  def purge(_, _, _), do: :ok

  @doc ~S"""
  Execute an uncached call to the cached function.

  ## Example

  ```elixir
  iex> CacheMe.uncached(MyExample, :url, [])
  "https://example.com"
  ```
  """
  @spec uncached(module :: module, function :: atom, args :: [any]) :: any
  def uncached(module, function, arguments)
  def uncached(m, f, a), do: apply(m, :"__cached_#{f}", a)

  import CacheMe.AST

  @doc @moduledoc
  defmacro __using__(opts \\ [])

  defmacro __using__(_opts) do
    unless Module.has_attribute?(__CALLER__.module, :cached_functions) do
      Module.register_attribute(__CALLER__.module, :cached_functions, accumulate: true)
      Module.put_attribute(__CALLER__.module, :cached, %{})

      quote do
        @cache false
        _ = @cache

        @on_definition {unquote(__MODULE__), :define}
        @before_compile {unquote(__MODULE__), :wrap}
      end
    end
  end

  @doc false
  defmacro wrap(env) do
    cached = Module.get_attribute(env.module, :cached, %{})
    functions = Module.get_attribute(env.module, :cached_functions, [])

    base =
      quote do
        defoverridable unquote(functions)
      end

    Enum.reduce(cached, base, fn {_index,
                                  %{
                                    kind: kind,
                                    name: name,
                                    args: args,
                                    cache: cache,
                                    function: function
                                  }},
                                 acc ->
      cache_mod =
        case Keyword.get(cache, :mechanic, :compile) do
          :compile -> CacheMe.Cache.Compile
          :ets -> CacheMe.Cache.ETS
        end

      quote do
        unquote(acc)
        @doc false
        unquote(function)
        unquote(cache_mod.generate(env.module, kind, name, args, cache))
      end
    end)
  end

  @doc false
  def define(env, kind, name, args, guards, body) do
    module = env.module
    arity = a.._ = arity(args)
    index = {name, a}

    cond do
      index in Module.get_attribute(module, :cached_functions, []) ->
        cached = Module.get_attribute(module, :cached, %{})
        cached = Map.update!(cached, index, &copy_function(&1, module, name, args, guards, body))
        Module.put_attribute(module, :cached, cached)

      cache = cache_opts(module) ->
        Enum.each(arity, &Module.put_attribute(module, :cached_functions, {name, &1}))

        to_cache =
          copy_function(
            %{
              kind: kind,
              name: name,
              args: args,
              cache: cache,
              function: nil
            },
            module,
            name,
            args,
            guards,
            body
          )

        cached = Module.get_attribute(module, :cached, %{})
        cached = Map.put(cached, index, to_cache)
        Module.put_attribute(module, :cached, cached)
        Module.delete_attribute(module, :cache)

      true ->
        :ok
    end
  end

  defp copy_function(cached, module, name, args, guards, body)
  defp copy_function(cached, _module, _name, _args, _guards, nil), do: cached

  defp copy_function(cached = %{function: acc}, module, name, args, guards, body) do
    name = :"__cached_#{name}"
    attrs = attributes(module, body)
    stripped = strip_defaults(args)

    updated =
      if Enum.empty?(guards) do
        quote do
          unquote(acc)
          unquote(Enum.map(attrs, fn {k, v} -> {:@, [], [{k, [], [Macro.escape(v)]}]} end))

          @doc false
          Kernel.unquote(:def)(unquote(name)(unquote_splicing(stripped)), unquote(body))
        end
      else
        quote do
          unquote(acc)
          unquote(Enum.map(attrs, fn {k, v} -> {:@, [], [{k, [], [Macro.escape(v)]}]} end))

          @doc false
          Kernel.unquote(:def)(
            unquote(name)(unquote_splicing(stripped)) when unquote_splicing(guards),
            unquote(body)
          )
        end
      end

    %{cached | function: updated}
  end

  defp cache_opts(module) do
    case Module.get_attribute(module, :cache, false) do
      false -> nil
      opts when is_list(opts) -> opts
      _ -> []
    end
  end
end
