# Some helper modules

defmodule Person do
  defstruct name: nil, age: nil
end

defmodule FakedRepo do
  def all(Person) do
    [
      %Person{name: "moshe", age: 25},
      %Person{name: "jacob", age: 35},
      %Person{name: "yossi", age: 45},
    ]
  end
end


defmodule Krihelinator.ImportExportTest do
  use Krihelinator.ModelCase, async: true
  import Krihelinator.ImportExport

  test "export_data" do
    json = export_data([Person], FakedRepo)
    list = Poison.decode!(json)
    [%{"model" => model_name, "items" => items}] = list
    assert model_name == "Elixir.Person"
    first_person = hd(items)
    assert first_person["name"] == "moshe"
    assert first_person["age"] == 25
  end

  test "export_krihelinator_data has data for each model" do
    json = export_krihelinator_data()
    list = Poison.decode!(json)
    model_names =
      list
      |> Enum.map(fn %{"model" => model_name} -> model_name end)
      |> Enum.into(MapSet.new())
    for name <- ~w(Repo Language) do
      assert MapSet.member?(model_names, "Elixir.Krihelinator.Github." <> name)
    end
    assert MapSet.member?(model_names, "Elixir.Krihelinator.History.Language")
  end

  test "import fixture and then export create the same content" do
    fixture = Path.join(["test", "fixtures", "dump_sample.json"])
    in_json = File.read!(fixture)
    import_data(in_json, Krihelinator.Repo)
    out_json = export_krihelinator_data()
    in_map = Poison.decode!(in_json)
    out_map = Poison.decode!(out_json)
    for {{in_model, in_items}, {out_model, out_items}} <- Enum.zip(in_map, out_map) do
      assert in_model == out_model
      assert length(in_items) == length(out_items)
      in_items = Enum.sort_by(in_items, fn x -> x["name"] end)
      out_items = Enum.sort_by(out_items, fn x -> x["name"] end)
      for {in_item, out_item} <- Enum.zip(in_items, out_items) do
        assert in_item == out_item
      end
    end
  end

  test "seed, export, delete all, and make sure import still works" do
    alias Krihelinator.Github, as: GH
    alias Krihelinator.History.Language, as: LanguageHistory

    # Seed

    elixir =
      %GH.Language{}
      |> GH.Language.changeset(%{name: "Elixir"})
      |> Krihelinator.Repo.insert!()

    repo_params = %{
      name: "my/repo", authors: 1, commits: 2,
      merged_pull_requests: 3, proposed_pull_requests: 4, closed_issues: 5,
      new_issues: 6, description: "my awesome project!", user_requested: true
    }
    %GH.Repo{}
    |> GH.Repo.changeset(repo_params)
    |> Ecto.Changeset.put_assoc(:language, elixir)
    |> Krihelinator.Repo.insert!()

    now = DateTime.utc_now()
    yesterday = Timex.shift(now, days: -1)
    for dt <- [now, yesterday] do
      %LanguageHistory{}
      |> LanguageHistory.changeset(%{krihelimeter: 100, timestamp: dt})
      |> Ecto.Changeset.put_assoc(:language, elixir)
      |> Krihelinator.Repo.insert!()
    end

    # Export

    json = export_krihelinator_data()

    # Delete all

    for model <- [GH.Repo, LanguageHistory, GH.Language] do
      Krihelinator.Repo.delete_all(model)
    end

    # Import

    import_data(json, Krihelinator.Repo)

    # Basic asserts

    histories = Krihelinator.Repo.all(LanguageHistory)
    assert length(histories) == 2
    [newer, older] = histories
    assert newer.timestamp == now
    assert older.timestamp == yesterday

    repo =
      GH.Repo
      |> Krihelinator.Repo.get_by(name: "my/repo")
      |> Krihelinator.Repo.preload(:language)

    assert repo.language.name == "Elixir"
  end

  test "insert new language succeeds after import. Bug #163" do

    # Reset the languages_id_seq to 1
    Ecto.Adapters.SQL.query(Krihelinator.Repo, "SELECT setval('languages_id_seq', 1);", [])

    # Import one language with id 2
    [
      %{
        model: "Elixir.Krihelinator.Github.Language",
        items: [
          %{id: 2, name: "MosheLang", krihelimeter: 1000}
        ]
      }
    ]
    |> Poison.encode!()
    |> import_data(Krihelinator.Repo)

    # Try to create a language with auto generated id
    jacob_lang_struct = %Krihelinator.Github.Language{name: "JacobLang"}
    {:ok, _struct} = Krihelinator.Repo.insert(jacob_lang_struct)
  end
end
