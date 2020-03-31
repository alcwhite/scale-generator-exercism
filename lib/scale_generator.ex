defmodule ScaleGenerator do

  @chromatic_sharp ~w(C C# D D# E F F# G G# A A# B)
  @chromatic_flat ~w(C Db D Eb E F Gb G Ab A Bb B)
  @flat_scales ~w(F Bb Eb Ab Db Gb d g c f bb eb)
  @step_names %{"m" => 1, "M" => 2, "A" => 3}
  @scale_patterns %{
    "major" => "MMmMMMm",
    "minor" => "MmMMmMM",
    "dorian" => "MmMMMmM",
    "mixolydian" => "MMmMMmM",
    "lydian" => "MMMmMMm",
    "phrygian" => "mMMMmMM",
    "locrian" => "mMMmMMM",
    "harmonic minor" => "MmMMmAm",
    "melodic minor" => "MmMMMMm",
    "octatonic" => "MmMmMmMm",
    "hexatonic" => "MMMMMM",
    "pentatonic" => "MMAMA",
    "enigmatic" => "mAMMMmm"}

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
    index = Enum.find_index(scale, fn x -> x === upcase_tonic(tonic) end)
    Enum.at(scale, index + @step_names[step])
  end
  @spec form_chromatic(list(String.t()), String.t()) :: list(String.t())
  def form_chromatic(scale, tonic) do
    index = Enum.find_index(scale, fn x -> x === upcase_tonic(tonic) end)
    Enum.slice(scale, index..Enum.count(scale)) ++ Enum.slice(scale, 0..index)
  end
  @spec find_chromatic_scale(tonic :: String.t()) :: list(String.t())
  def find_chromatic_scale(tonic) do
    if Enum.member?(@flat_scales, tonic) do
      flat_chromatic_scale(tonic)
    else
      chromatic_scale(tonic)
    end
  end

  @spec chromatic_scale(tonic :: String.t()) :: list(String.t())
  def chromatic_scale(tonic \\ "C") do
    form_chromatic(@chromatic_sharp, tonic)
  end
  @spec flat_chromatic_scale(tonic :: String.t()) :: list(String.t())
  def flat_chromatic_scale(tonic \\ "C") do
    form_chromatic(@chromatic_flat, tonic)
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

  @spec scale_by_name(tonic :: String.t(), name :: String.t()) :: list(String.t())
  def scale_by_name(tonic, name) do
    pattern = @scale_patterns[String.downcase(name)]
    scale(tonic, pattern)
  end
end
