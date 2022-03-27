defmodule CacheMe.Cache.ETS do
  @moduledoc false
  import CacheMe.AST, only: [strip_defaults: 1]

  def generate(module, kind, name, args, opts) do
    cache = :"__cache_#{module}__#{name}_#{Enum.count(args)}"
    original = :"__cached_#{name}"
    stripped = strip_defaults(args)
    key = Macro.var(:key, nil)

    ttl =
      case Keyword.get(opts, :ttl, :infinity) do
        :infinity ->
          nil

        time when is_integer(time) and time > 0 ->
          quote do
            Process.send_after(
              unquote(__MODULE__),
              {:ttl, unquote(cache), unquote(key)},
              unquote(time)
            )
          end
      end

    cached =
      quote do
        unquote(key) = {unquote(name), unquote_splicing(stripped)}

        try do
          case :ets.lookup(unquote(cache), unquote(key)) do
            [{_, v}] ->
              v

            _ ->
              result = unquote(original)(unquote_splicing(stripped))
              :ets.insert(unquote(cache), {unquote(key), result})
              unquote(ttl)
              result
          end
        rescue
          _ ->
            unquote(__MODULE__).create(unquote(cache))
            unquote(name)(unquote_splicing(stripped))
        end
      end

    quote do
      Kernel.unquote(kind)(unquote(name)(unquote_splicing(args)), unquote(do: cached))
    end
  end

  ### Management ###
  use GenServer

  def create(table, opts \\ [:named_table, :set, :public, read_concurrency: true])
  def create(table, opts), do: GenServer.call(__MODULE__, {:create, table, opts})

  def start_link(opts \\ [])
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @impl GenServer
  def init(opts)
  def init(_), do: {:ok, []}

  @impl GenServer
  def handle_call({:create, name, opts}, _from, tables) do
    if name in tables do
      {:reply, :ok, tables}
    else
      :ets.new(name, opts)
      {:reply, :ok, [name | tables]}
    end
  end

  @impl GenServer
  def handle_info({:ttl, name, key}, tables) do
    :ets.delete(name, key)
    {:noreply, tables}
  end
end
