defmodule ScaleGenerator do
 
  @spec chromatic_sharp() :: list(String.t())
  def chromatic_sharp() do ~w(C C# D D# E F F# G G# A A# B) end
  @spec chromatic_flat() :: list(String.t())
  def chromatic_flat() do ~w(C Db D Eb E F Gb G Ab A Bb B) end
  @spec flat_scales() :: list(String.t())
  def flat_scales() do ~w(F Bb Eb Ab Db Gb d g c f bb eb) end

  @spec upcase_tonic(String.t()) :: String.t()
  def upcase_tonic(tonic) do
    if String.length(tonic) === 1 do 
      String.upcase(tonic) 
    else
      String.upcase(String.at(tonic, 0)) <> String.at(tonic, 1)
    end
  end

  @spec step(scale :: list(String.t()), tonic :: String.t(), step :: String.t()) :: list(String.t())
  def step(scale, tonic, step) do
    index = Enum.find_index(scale, fn x -> x === tonic end)
    case step do
      "m" -> Enum.find(scale, fn x -> Enum.find_index(scale, fn y -> y === x end) === index + 1 end)
      "M" -> Enum.find(scale, fn x -> Enum.find_index(scale, fn y -> y === x end) === index + 2 end)
      "A" -> Enum.find(scale, fn x -> Enum.find_index(scale, fn y -> y === x end) === index + 3 end)
    end
  end

  @spec split_chromatic(list(String.t()), atom, pos_integer) :: list(String.t())
  def split_chromatic(scale, half, index) do
    case half do
      :less -> fn x -> Enum.find_index(scale, fn y -> y === x end) < index end
      :greater -> fn x -> Enum.find_index(scale, fn y -> y === x end) > index end
    end
  end
  @spec concat_chromatic(list(String.t()), String.t()) :: list(String.t())
  def concat_chromatic(scale, tonic) do
    tonic = upcase_tonic(tonic)
    index = Enum.find_index(scale, fn x -> x === tonic end)
    Enum.reject(scale, split_chromatic(scale, :less, index)) ++ Enum.reject(scale, split_chromatic(scale, :greater, index))
  end

  @spec chromatic_scale(tonic :: String.t()) :: list(String.t())
  def chromatic_scale(tonic \\ "C") do
    concat_chromatic(chromatic_sharp(), tonic)
  end
  @spec flat_chromatic_scale(tonic :: String.t()) :: list(String.t())
  def flat_chromatic_scale(tonic \\ "C") do
    concat_chromatic(chromatic_flat(), tonic)
  end
  
  @spec find_chromatic_scale(tonic :: String.t()) :: list(String.t())
  def find_chromatic_scale(tonic) do
    if Enum.member?(flat_scales(), tonic) do
      flat_chromatic_scale(tonic)
    else
      chromatic_scale(tonic)
    end
  end

  @spec add_note({list(String.t()), String.t(), list(String.t()), pos_integer, pos_integer}) :: any
  def add_note({scale, pattern, chromatic, scale_length, pattern_length}) when scale_length < pattern_length do
    next_note = step(chromatic, Enum.at(scale, scale_length - 1), String.at(pattern, scale_length - 1))
    add_note({scale ++ [next_note], pattern, chromatic, scale_length + 1, pattern_length})
  end
  def add_note({scale, _pattern, _chromatic, scale_length, pattern_length}) when scale_length === pattern_length do
    scale ++ [Enum.at(scale, 0)]
  end

  @spec scale(tonic :: String.t(), pattern :: String.t()) :: list(String.t())
  def scale(tonic, pattern) do
    chromatic = find_chromatic_scale(tonic)
    add_note({[upcase_tonic(tonic)], pattern, chromatic, 1, String.length(pattern)})
  end
end
